#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum {
    kMagic = 0x53534E52,
    kVersion = 1,
    kPlayerCount = 4,
    kDefaultFrameCount = 3600,
    kHistoryLength = 720,
    kFnvPrime = 16777619,
    kFnvOffset = 2166136261U,
};

typedef struct {
    uint32_t magic;
    uint32_t version;
    uint32_t metadata_size;
    uint32_t frame_size;
    uint32_t frame_count;
    uint32_t player_count;
    uint32_t input_checksum;
} ReplayHeader;

typedef struct {
    uint32_t magic;
    uint32_t version;
    uint32_t scene_kind;
    uint32_t player_count;
    uint32_t stage_kind;
    uint32_t stocks;
    uint32_t time_limit;
    uint32_t item_switch;
    uint32_t item_toggles;
    uint32_t rng_seed;
    uint8_t game_type;
    uint8_t game_rules;
    uint8_t is_team_battle;
    uint8_t handicap;
    uint8_t is_team_attack;
    uint8_t is_stage_select;
    uint8_t damage_ratio;
    uint8_t item_appearance_rate;
    uint8_t is_not_teamshadows;
    uint8_t player_kinds[kPlayerCount];
    uint8_t fighter_kinds[kPlayerCount];
    uint8_t costumes[kPlayerCount];
    uint8_t teams[kPlayerCount];
    uint8_t handicaps[kPlayerCount];
    uint8_t levels[kPlayerCount];
    uint8_t shades[kPlayerCount];
    uint8_t padding[3];
} ReplayMetadata;

typedef struct {
    uint32_t tick;
    uint16_t buttons;
    int8_t stick_x;
    int8_t stick_y;
    uint8_t source;
    uint8_t is_predicted;
    uint8_t is_valid;
    uint8_t padding;
} ReplayFrame;

_Static_assert(sizeof(ReplayHeader) == 28, "unexpected replay-header layout");
_Static_assert(sizeof(ReplayMetadata) == 80, "unexpected replay-metadata layout");
_Static_assert(sizeof(ReplayFrame) == 12, "unexpected replay-frame layout");

static uint32_t checksum_frame(uint32_t checksum, uint32_t player, const ReplayFrame *frame) {
    checksum = (checksum ^ player) * kFnvPrime;
    checksum = (checksum ^ frame->tick) * kFnvPrime;
    checksum = (checksum ^ frame->buttons) * kFnvPrime;
    checksum = (checksum ^ (uint8_t)frame->stick_x) * kFnvPrime;
    checksum = (checksum ^ (uint8_t)frame->stick_y) * kFnvPrime;
    return checksum;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s OUTPUT_REPLAY\n", argv[0]);
        return 2;
    }

    ReplayMetadata metadata = {0};
    metadata.magic = kMagic;
    metadata.version = kVersion;
    metadata.scene_kind = 22;          /* nSCKindVSBattle */
    metadata.player_count = 2;
    metadata.stage_kind = 6;           /* nGRKindPupupu (Dream Land) */
    metadata.stocks = 2;
    metadata.time_limit = 1;           /* one-minute time match */
    metadata.item_switch = 4;
    metadata.item_toggles = 0;
    metadata.rng_seed = 0x42505752;
    metadata.game_type = 1;            /* nSCBattleGameTypeRoyal */
    metadata.game_rules = 1;           /* SCBATTLE_GAMERULE_TIME */
    metadata.damage_ratio = 100;
    metadata.item_appearance_rate = 4;
    metadata.player_kinds[0] = 0;      /* nFTPlayerKindMan */
    metadata.player_kinds[1] = 1;      /* nFTPlayerKindCom */
    metadata.player_kinds[2] = 2;      /* nFTPlayerKindNot */
    metadata.player_kinds[3] = 2;
    metadata.fighter_kinds[0] = 0;     /* Mario */
    metadata.fighter_kinds[1] = 1;     /* Fox */
    metadata.teams[0] = 0;
    metadata.teams[1] = 1;
    for (uint32_t player = 0; player < kPlayerCount; ++player) {
        metadata.handicaps[player] = 9;
        metadata.levels[player] = (player < 2) ? 9 : 3;
    }

    ReplayFrame frame = {0};
    frame.source = 3;                  /* nSYNetInputSourceSaved */
    frame.is_valid = 1;

    uint32_t checksum = kFnvOffset;
    /*
     * BattleShip verifies against its 720-frame circular history. At the end
     * of a longer replay, older ticks have been overwritten and are skipped
     * by syNetInputGetHistoryInputChecksum(). Mirror that behavior here so
     * the fixture exercises the upstream verifier without a false mismatch.
     */
    uint32_t checksum_start =
        (kDefaultFrameCount > kHistoryLength) ? kDefaultFrameCount - kHistoryLength : 0;
    for (uint32_t tick = checksum_start; tick < kDefaultFrameCount; ++tick) {
        frame.tick = tick;
        for (uint32_t player = 0; player < kPlayerCount; ++player) {
            checksum = checksum_frame(checksum, player, &frame);
        }
    }

    ReplayHeader header = {
        .magic = kMagic,
        .version = kVersion,
        .metadata_size = sizeof(metadata),
        .frame_size = sizeof(frame),
        .frame_count = kDefaultFrameCount,
        .player_count = kPlayerCount,
        .input_checksum = checksum,
    };

    FILE *output = fopen(argv[1], "wb");
    if (output == NULL) {
        perror("fopen");
        return 1;
    }
    if (fwrite(&header, sizeof(header), 1, output) != 1 ||
        fwrite(&metadata, sizeof(metadata), 1, output) != 1) {
        perror("fwrite");
        fclose(output);
        return 1;
    }
    for (uint32_t tick = 0; tick < kDefaultFrameCount; ++tick) {
        frame.tick = tick;
        for (uint32_t player = 0; player < kPlayerCount; ++player) {
            if (fwrite(&frame, sizeof(frame), 1, output) != 1) {
                perror("fwrite");
                fclose(output);
                return 1;
            }
        }
    }
    if (fclose(output) != 0) {
        perror("fclose");
        return 1;
    }
    printf("wrote %s (%u frames, checksum 0x%08X)\n",
           argv[1], kDefaultFrameCount, checksum);
    return 0;
}
