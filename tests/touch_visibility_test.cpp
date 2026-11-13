#include "brawlerpad_touch_visibility.h"

#include <cstdlib>
#include <iostream>
#include <string>

namespace {
using BrawlerPadTouch::Preferences;

void Expect(bool condition, const std::string& message) {
    if (!condition) {
        std::cerr << "touch visibility regression failed: " << message << '\n';
        std::exit(1);
    }
}

bool Visible(const Preferences& preferences, bool physical) {
    return BrawlerPadTouch::GameplayControlsVisible(preferences, physical);
}
} // namespace

int main() {
    Preferences preferences; // no saved choice: both settings default on
    Expect(Visible(preferences, false), "touch hidden without a controller");
    Expect(!Visible(preferences, true), "default did not hide touch for a physical controller");

    // The existing opt-out still restores touch with the controller connected.
    preferences.hideWithController = false;
    Expect(Visible(preferences, true), "opt-out did not keep touch visible");
    preferences.hideWithController = true;

    // Show recovers a manual hide while the controller stays connected and
    // turns the saved auto-hide preference off.
    preferences.touchControls = false;
    Expect(!Visible(preferences, true) && !Visible(preferences, false), "manual hide was not respected");
    preferences = BrawlerPadTouch::ShowTouchControls(preferences);
    Expect(preferences.touchControls && !preferences.hideWithController, "Show did not update both preferences");
    Expect(Visible(preferences, true), "Show did not restore touch with a controller connected");
    Expect(Visible(preferences, false), "Show did not keep touch visible after disconnect");

    // Turning auto-hide back on applies to the current controller at once.
    preferences.hideWithController = true;
    Expect(!Visible(preferences, true), "re-enabled auto-hide ignored the connected controller");

    std::cout << "touch visibility regression passed\n";
    return 0;
}
