#include <stdio.h>
#include <stdlib.h>
#include <filesystem>
#include <iostream>
#include <array>

extern "C"
{
    extern unsigned char swfData[];
    extern int swfSize;
    extern unsigned char swcData[];
    extern int swcSize;
}

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

std::string sanitizeContentsPath(const std::string &p)
{
    std::string ret = p;
    static constexpr std::array<std::pair<std::string_view, std::string_view>, 1> REPLACE_RULES = {{{"%20", " "}}};

    for (const auto &rule : REPLACE_RULES)
    {
        size_t found = ret.find(rule.first);
        while (found != std::string::npos)
        {
            ret.replace(found, rule.first.length(), rule.second);
            found = ret.find(rule.first);
        }
    }

    return ret;
}

int main()
{
    std::error_code ec;

    const std::filesystem::path metadataFile{"META-INF/AIR/application.xml"};
    const std::filesystem::path metadataBkpFile{"META-INF/AIR/application.xml.bkp"};
    const std::filesystem::path gamePathFile{"game-file.txt"};

    if (!std::filesystem::exists(metadataBkpFile))
    {
        std::filesystem::copy_file(metadataFile, metadataBkpFile, std::filesystem::copy_options::overwrite_existing);
    }

    if (!std::filesystem::exists(metadataFile))
    {
        waitExit("Metadata file does not exist.", -3);
    }

    FILE *inFile = _wfopen(metadataBkpFile.generic_wstring().c_str(), L"rt");
    if (!inFile)
    {
        waitExit("Metadata file could not be opened for reading.", -5);
    }
    std::string metadata{static_cast<std::string::size_type>(std::filesystem::file_size(metadataBkpFile)), '\0', std::allocator<char>()};
    fread(metadata.data(), 1, metadata.size(), inFile);
    fclose(inFile);

    metadata = metadata.substr(0, metadata.find_first_of('\0'));

    const auto idStart = metadata.find("<id>");
    const auto idEnd = metadata.find("</id>");

    if (idStart == std::string::npos || idEnd == std::string::npos)
    {
        waitExit("No ID within the metadata XML.", -4);
    }

    const std::string gameID = metadata.substr(idStart + 4, idEnd - idStart - 4);

    const auto contentStart = metadata.find("<content>");
    const auto contentEnd = metadata.find("</content>");

    if (contentStart == std::string::npos || contentEnd == std::string::npos)
    {
        waitExit("No SWF content tag within the metadata XML.", -6);
    }

    const std::filesystem::path contentPath{sanitizeContentsPath(metadata.substr(contentStart + 9, contentEnd - contentStart - 9))};
    const std::filesystem::path moddedPath{contentPath.stem().generic_wstring() + L"-modded" + contentPath.extension().generic_wstring()};

    metadata.replace(metadata.cbegin() + contentStart + 9, metadata.cbegin() + contentEnd, "Mods/BezelModLoader.swf");

    const std::filesystem::path bezelFile{"Mods/BezelModLoader.swf"};
    const std::filesystem::path bezelLibrary{"Mods/BezelModLoader.swc"};

    std::filesystem::path appdata{getenv("APPDATA")};
    if (std::filesystem::exists(appdata))
    {
        std::filesystem::path gcfwData = appdata / gameID / "Local Store";
        if (std::filesystem::exists(gcfwData))
        {
            // Intentionally ignore these errors; if they don't exist there's no issue
            try
            {
                // Before files were moved to subfolder
                std::filesystem::remove(gcfwData / "coremods.bzl", ec);
                std::filesystem::remove(gcfwData / "coremods.lttc", ec);
                std::filesystem::remove(gcfwData / "gcfw.basasm", ec);
                std::filesystem::remove(gcfwData / "gcfw-clean.basasm", ec);

                std::filesystem::remove(gcfwData / "Bezel Mod Loader" / "coremods.bzl", ec);
                std::filesystem::remove(gcfwData / "Bezel Mod Loader" / "Lattice" / "coremods.lttc", ec);
                std::filesystem::remove(gcfwData / "Bezel Mod Loader" / "Lattice" / "gcfw.basasm", ec);
                std::filesystem::remove(gcfwData / "Bezel Mod Loader" / "Lattice" / "gcfw-clean.basasm", ec);
                std::filesystem::remove(gcfwData / "Bezel Mod Loader" / "Lattice" / "game.basasm", ec);
                std::filesystem::remove(gcfwData / "Bezel Mod Loader" / "Lattice" / "game-clean.basasm", ec);

                // In case tools are updated
                std::filesystem::remove_all(gcfwData / "Bezel Mod Loader" / "tools", ec);
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
    std::filesystem::remove(moddedPath, ec);
    std::filesystem::create_directory("Mods", ec);

    if (ec)
    {
        waitExit("Could not create directory for Bezel and mods. No changes have been made.", ec.value());
    }

    FILE *outFile = _wfopen(bezelFile.generic_wstring().c_str(), L"wb");
    fwrite(swfData, 1, swfSize, outFile);
    fclose(outFile);

    outFile = _wfopen(bezelLibrary.generic_wstring().c_str(), L"wb");
    fwrite(swcData, 1, swcSize, outFile);
    fclose(outFile);

    outFile = _wfopen(metadataFile.generic_wstring().c_str(), L"wt");
    fwrite(metadata.data(), 1, metadata.size(), outFile);
    fclose(outFile);

    if (!std::filesystem::exists(gamePathFile))
    {
        outFile = _wfopen(gamePathFile.generic_wstring().c_str(), L"wt");
        fwrite(contentPath.string().c_str(), 1, contentPath.string().length(), outFile);
        fclose(outFile);
    }

    waitExit("Installation succeeded.", 0);
}
