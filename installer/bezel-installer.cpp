#include <stdio.h>
#include <stdlib.h>
#include <filesystem>
#include <iostream>

extern unsigned char swfData[] asm("swfData");
extern int swfSize asm("swfSize");

[[noreturn]] void waitExit(const char *exitMessage, int exitCode)
{
    printf("%s\n", exitMessage);
    if (exitCode != 0)
    {
        printf("Installation failed. This should be run from your GCFW folder, findable through Steam's \"Browse Local Files\". If you are running this in the correct place, please file a bug report.\n");
        printf("Exit code: %i (please provide this if you're making a bug report!)\n", exitCode);
    }
    char trash[2];
    printf("Hit any key to exit");
    std::cin.read(trash, 1);
    exit(exitCode);
}

int main()
{
    std::error_code ec;

    const std::filesystem::path metadataFile{"META-INF/AIR/application.xml"};
    const std::filesystem::path metadataBkpFile{"META-INF/AIR/application.xml.bkp"};
    const std::filesystem::path gcfwBkpFile{"GemCraft Frostborn Wrath Backup.swf"};

    if (std::filesystem::exists(gcfwBkpFile))
    {
        std::filesystem::remove("GemCraft Frostborn Wrath.swf");
        std::filesystem::rename(gcfwBkpFile, "GemCraft Frostborn Wrath.swf");
    }

    if (!std::filesystem::exists(metadataFile))
    {
        waitExit("Metadata file does not exist.", -3);
    }

    if (!std::filesystem::exists(metadataBkpFile))
    {
        std::filesystem::copy_file(metadataFile, metadataBkpFile, std::filesystem::copy_options::overwrite_existing);
    }

    FILE *inFile = _wfopen(metadataFile.generic_wstring().c_str(), L"rt");
    if (!inFile)
    {
        waitExit("Metadata file could not be opened for reading.", -5);
    }
    std::string metadata{static_cast<std::string::size_type>(std::filesystem::file_size(metadataFile)), '\0', std::allocator<char>()};
    fread(metadata.data(), 1, metadata.size(), inFile);
    fclose(inFile);

    metadata = metadata.substr(0, metadata.find_first_of('\0'));

    auto tagStart = metadata.find("<id>");
    auto tagEnd = metadata.find("</id>");

    if (tagStart == std::string::npos || tagEnd == std::string::npos)
    {
        waitExit("No ID within the metadata XML.", -4);
    }

    tagStart += 4;

    std::string gameID = metadata.substr(tagStart, tagEnd - tagStart);

    std::filesystem::path appdata{getenv("APPDATA")};
    if (std::filesystem::exists(appdata))
    {
        std::filesystem::path gcfwData = appdata / gameID / "Local Store";
        if (std::filesystem::exists(gcfwData))
        {
            // Intentionally ignore these errors; if they don't exist there's no issue
            try
            {
                std::filesystem::remove(gcfwData / "coremods.bzl");
                std::filesystem::remove(gcfwData / "coremods.lttc");
                std::filesystem::remove(gcfwData / "gcfw.basasm");
                std::filesystem::remove(gcfwData / "gcfw-clean.basasm");
            }
            catch (std::filesystem::filesystem_error &e)
            {
                waitExit("Could not remove previous Bezel's temporary files from application storage directory.", e.code().value());
            }
        }
    }
    else
    {
        waitExit("Could not locate %APPDATA%.", -1);
    }

    std::filesystem::remove("gcfw-modded.swf", ec);

    tagStart = metadata.find("<content>");
    tagEnd = metadata.find("</content>");

    if (tagStart == std::string::npos || tagEnd == std::string::npos)
    {
        waitExit("No SWF content tag within the metadata XML.", -6);
    }

    tagStart += 9;

    metadata.replace(metadata.cbegin() + tagStart, metadata.cbegin() + tagEnd, "Mods/BezelModLoader.swf");

    const std::filesystem::path bezelFile{"Mods/BezelModLoader.swf"};

    std::filesystem::create_directory("Mods", ec);

    if (ec)
    {
        waitExit("Could not create directory for Bezel and mods. No changes have been made.", ec.value());
    }

    FILE *outFile = _wfopen(bezelFile.generic_wstring().c_str(), L"wb");
    fwrite(swfData, 1, swfSize, outFile);
    fclose(outFile);

    outFile = _wfopen(metadataFile.generic_wstring().c_str(), L"wt");
    fwrite(metadata.data(), 1, metadata.size(), outFile);
    fclose(outFile);

    waitExit("Installation succeeded.", 0);
}
