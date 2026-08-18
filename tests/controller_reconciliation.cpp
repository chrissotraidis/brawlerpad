#include <SDL2/SDL.h>

#include <algorithm>
#include <cstdlib>
#include <iostream>
#include <vector>

#include "ship/controller/physicaldevice/ConnectedPhysicalDeviceManager.h"

namespace {

[[noreturn]] void Fail(const char* message) {
    std::cerr << "controller reconciliation test failed: " << message << '\n';
    std::exit(EXIT_FAILURE);
}

void Require(bool condition, const char* message) {
    if (!condition) {
        Fail(message);
    }
}

class VirtualGamepads {
  public:
    ~VirtualGamepads() {
        while (!mDeviceIndexes.empty()) {
            Detach(mDeviceIndexes.back());
        }
    }

    int Attach() {
        const int deviceIndex = SDL_JoystickAttachVirtual(SDL_JOYSTICK_TYPE_GAMECONTROLLER, SDL_CONTROLLER_AXIS_MAX,
                                                          SDL_CONTROLLER_BUTTON_MAX, 0);
        Require(deviceIndex >= 0, SDL_GetError());
        mDeviceIndexes.push_back(deviceIndex);
        return deviceIndex;
    }

    void Detach(int deviceIndex) {
        Require(SDL_JoystickDetachVirtual(deviceIndex) == 0, SDL_GetError());
        mDeviceIndexes.erase(std::remove(mDeviceIndexes.begin(), mDeviceIndexes.end(), deviceIndex),
                             mDeviceIndexes.end());
        for (int& remainingDeviceIndex : mDeviceIndexes) {
            if (remainingDeviceIndex > deviceIndex) {
                --remainingDeviceIndex;
            }
        }
    }

  private:
    std::vector<int> mDeviceIndexes;
};

void TestMissedRemovalAndPlayerOneReclaim() {
    Ship::ConnectedPhysicalDeviceManager manager;
    VirtualGamepads gamepads;
    const int firstDeviceIndex = gamepads.Attach();
    const SDL_JoystickID firstInstanceId = SDL_JoystickGetDeviceInstanceID(firstDeviceIndex);
    Require(firstInstanceId >= 0, SDL_GetError());

    manager.ReconcileConnectedSDLGamepads("test-initial");
    auto playerOne = manager.GetConnectedSDLGamepadsForPort(0);
    Require(playerOne.contains(firstInstanceId), "initial gamepad was not assigned to player 1");
    Require(SDL_JoystickSetVirtualButton(SDL_GameControllerGetJoystick(playerOne.at(firstInstanceId)),
                                        SDL_CONTROLLER_BUTTON_A, 1) == 0,
            SDL_GetError());
    Require(SDL_JoystickSetVirtualAxis(SDL_GameControllerGetJoystick(playerOne.at(firstInstanceId)),
                                      SDL_CONTROLLER_AXIS_LEFTX, 16000) == 0,
            SDL_GetError());
    SDL_GameControllerUpdate();
    Require(SDL_GameControllerGetButton(playerOne.at(firstInstanceId), SDL_CONTROLLER_BUTTON_A) == 1,
            "held test button was not visible before disconnect");
    Require(SDL_GameControllerGetAxis(playerOne.at(firstInstanceId), SDL_CONTROLLER_AXIS_LEFTX) == 16000,
            "held test axis was not visible before disconnect");

    // Deliberately omit SDL_CONTROLLERDEVICEREMOVED: this models a missed event during controller sleep.
    gamepads.Detach(firstDeviceIndex);
    manager.ReconcileConnectedSDLGamepads("test-missed-removal");
    Require(manager.GetConnectedSDLGamepadsForPort(0).empty(),
            "stale player-1 handle survived missed removal instead of neutralizing input");

    const int returningDeviceIndex = gamepads.Attach();
    const SDL_JoystickID returningInstanceId = SDL_JoystickGetDeviceInstanceID(returningDeviceIndex);
    Require(returningInstanceId >= 0, SDL_GetError());
    manager.ReconcileConnectedSDLGamepads("test-returning-controller");
    Require(manager.GetConnectedSDLGamepadsForPort(0).contains(returningInstanceId),
            "sole returning controller did not reclaim player 1");
}

void TestTwoPlayerAssignmentAndForegroundReconciliation() {
    Ship::ConnectedPhysicalDeviceManager manager;
    VirtualGamepads gamepads;
    const int firstDeviceIndex = gamepads.Attach();
    const int secondDeviceIndex = gamepads.Attach();
    const SDL_JoystickID firstInstanceId = SDL_JoystickGetDeviceInstanceID(firstDeviceIndex);
    const SDL_JoystickID secondInstanceId = SDL_JoystickGetDeviceInstanceID(secondDeviceIndex);

    manager.ReconcileConnectedSDLGamepads("test-two-controllers");
    Require(manager.GetConnectedSDLGamepadsForPort(0).contains(firstInstanceId),
            "first controller was not assigned to player 1");
    Require(manager.GetConnectedSDLGamepadsForPort(1).contains(secondInstanceId),
            "second controller was not assigned to player 2");

    // Again omit the removal event. Replacing player 2 must not displace player 1.
    gamepads.Detach(secondDeviceIndex);
    const int replacementDeviceIndex = gamepads.Attach();
    const SDL_JoystickID replacementInstanceId = SDL_JoystickGetDeviceInstanceID(replacementDeviceIndex);
    manager.ReconcileConnectedSDLGamepads("test-second-controller-replaced");
    Require(manager.GetConnectedSDLGamepadsForPort(0).contains(firstInstanceId),
            "player 1 moved when player 2 changed");
    Require(manager.GetConnectedSDLGamepadsForPort(1).contains(replacementInstanceId),
            "replacement controller did not take the next free player slot");

    manager.ReconcileConnectedSDLGamepads("foreground");
    Require(manager.GetConnectedSDLGamepadsForPort(0).contains(firstInstanceId),
            "foreground reconciliation displaced player 1");
    Require(manager.GetConnectedSDLGamepadsForPort(1).contains(replacementInstanceId),
            "foreground reconciliation lost player 2");
}

} // namespace

int main() {
    if (SDL_Init(SDL_INIT_GAMECONTROLLER | SDL_INIT_EVENTS) != 0) {
        std::cerr << "controller reconciliation test could not initialize SDL: " << SDL_GetError() << '\n';
        return EXIT_FAILURE;
    }
    if (SDL_NumJoysticks() != 0) {
        std::cerr << "controller reconciliation test requires no host gamepads; skipping\n";
        SDL_Quit();
        return 77;
    }

    TestMissedRemovalAndPlayerOneReclaim();
    TestTwoPlayerAssignmentAndForegroundReconciliation();
    SDL_Quit();
    std::cout << "controller reconciliation tests passed\n";
    return EXIT_SUCCESS;
}
