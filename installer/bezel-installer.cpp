#include <stdio.h>
#include <stdlib.h>
#include <filesystem>
#include <iostream>

extern unsigned char swfData[] asm("swfData");
extern int swfSize asm("swfSize");

void waitExit(const char *exitMessage, int exitCode)
{
    printf(exitMessage);
    if (exitCode != 0)
    {
        printf("%i", exitCode);
    }
    char trash[2];
    std::cin.read(trash, 1);
    exit(exitCode);
}

int main()
{
    std::error_code trashError;

    std::filesystem::path appdata{getenv("APPDATA")};
    if (std::filesystem::exists(appdata))
    {
        std::filesystem::path gcfwData = appdata / "com.giab.games.gcfw.steam" / "Local Store";
        if (std::filesystem::exists(gcfwData))
        {
            std::filesystem::remove(gcfwData / "coremods.bzl", trashError);
            std::filesystem::remove(gcfwData / "coremods.lttc", trashError);
            std::filesystem::remove(gcfwData / "gcfw.basasm", trashError);
            std::filesystem::remove(gcfwData / "gcfw-clean.basasm", trashError);
        }
    }
    else
    {
        waitExit("Could not locate %APPDATA%", -1);
    }

    std::filesystem::remove("gcfw-modded.swf", trashError);

    std::filesystem::path gameFile{"GemCraft Frostborn Wrath.swf"};

    try
    {
        if (std::filesystem::file_size(gameFile) > 100 * 1024 * 1024)
        {
            std::filesystem::rename(gameFile, "GemCraft Frostborn Wrath Backup.swf");
            FILE *out = _wfopen(gameFile.generic_wstring().c_str(), L"wb");
            fwrite(swfData, 1, swfSize, out);
            fclose(out);

            waitExit("Installation succeeded. Press enter to exit.", 0);
        }
        else
        {
            waitExit("Bezel appears to already be installed. If this is not correct, please file a bug report.", -2);
        }
    }
    catch (std::filesystem::filesystem_error &e)
    {
        waitExit("Installation failed. This should be run from your GCFW folder, findable through Steam's \"Browse Local Files\". If you are running this in the correct place, please file a bug report.", e.code().value());
    }

    return 0;
}
