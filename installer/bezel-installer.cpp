#include <array>
#include <filesystem>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <zip.h>

extern "C" {
extern unsigned char swfData[];
extern int swfSize;
extern unsigned char swcData[];
extern int swcSize;
extern unsigned char gccsLoaderData[];
extern int gccsLoaderSize;
extern unsigned char gcfwLoaderData[];
extern int gcfwLoaderSize;
extern unsigned char aneData[];
extern int aneSize;
extern unsigned char aneSwcData[];
extern int aneSwcSize;
}

[[noreturn]] void waitExit(const char* exitMessage, int exitCode)
{
    printf("%s\n", exitMessage);
    if (exitCode != 0)
    {
        printf("Installation failed. This should be run from your GCFW folder, findable through "
               "Steam's \"Browse Local Files\". If you are running this in the correct place, "
               "please file a bug report.\n");
        printf("Exit code: %i (please provide this if you're making a bug report!)\n", exitCode);
    }
    char trash;
    printf("Hit enter to exit");
    std::scanf("%c", &trash);
    exit(exitCode);
}

std::string sanitizeContentsPath(const std::string& p)
{
    std::string ret                                                                             = p;
    static constexpr std::array<std::pair<std::string_view, std::string_view>, 1> REPLACE_RULES = {
        {{"%20", " "}}};

    for (const auto& rule : REPLACE_RULES)
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

    if (!std::filesystem::exists(metadataFile))
    {
        waitExit(
            "Metadata file does not exist. Are you sure this is the game's install location?", -3);
    }

    if (!std::filesystem::exists(metadataBkpFile))
    {
        std::filesystem::copy_file(
            metadataFile, metadataBkpFile, std::filesystem::copy_options::overwrite_existing);
    }

    FILE* inFile = _wfopen(metadataBkpFile.generic_wstring().c_str(), L"rt");
    if (!inFile)
    {
        waitExit("Metadata file could not be opened for reading.", -5);
    }
    std::string metadata{
        static_cast<std::string::size_type>(std::filesystem::file_size(metadataBkpFile)), '\0',
        std::allocator<char>()};
    fread(metadata.data(), 1, metadata.size(), inFile);
    fclose(inFile);

    metadata = metadata.substr(0, metadata.find_first_of('\0'));

    const auto idStart = metadata.find("<id>");
    const auto idEnd   = metadata.find("</id>");

    if (idStart == std::string::npos || idEnd == std::string::npos)
    {
        waitExit("No ID within the metadata XML.", -4);
    }

    const std::string gameID = metadata.substr(idStart + 4, idEnd - idStart - 4);

    const auto contentStart = metadata.find("<content>");
    const auto contentEnd   = metadata.find("</content>");

    if (contentStart == std::string::npos || contentEnd == std::string::npos)
    {
        waitExit("No SWF content tag within the metadata XML.", -6);
    }

    const std::string contentName =
        sanitizeContentsPath(metadata.substr(contentStart + 9, contentEnd - contentStart - 9));

    const std::filesystem::path contentPath{contentName};
    const std::filesystem::path moddedPath{contentPath.stem().generic_wstring() + L"-modded" +
                                           contentPath.extension().generic_wstring()};

    metadata.replace(metadata.cbegin() + contentStart + 9, metadata.cbegin() + contentEnd,
        "Bezel/BezelModLoader.swf");

    const auto extensionEnd = metadata.find("</extensionID>");
    metadata.insert(
        extensionEnd + 14, "<extensionID>com.cff.anebe.ANEBytecodeEditor</extensionID>");

    const std::filesystem::path oldBezelFile{"Mods/BezelModLoader.swf"};
    const std::filesystem::path oldBezelLibrary{"Mods/BezelModLoader.swc"};
    const std::filesystem::path bezelFile{"Bezel/BezelModLoader.swf"};
    const std::filesystem::path mainLoaderPath{"Bezel/MainLoader.swf"};

    if (!_wgetenv(L"APPDATA"))
    {
        waitExit("%APPDATA% does not exist", -7);
    }

    const std::filesystem::path appdata{_wgetenv(L"APPDATA")};
    if (std::filesystem::exists(appdata))
    {
        const std::filesystem::path gcfwData = appdata / gameID / "Local Store";
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
                std::filesystem::remove(
                    gcfwData / "Bezel Mod Loader" / "Lattice" / "coremods.lttc", ec);
                std::filesystem::remove(
                    gcfwData / "Bezel Mod Loader" / "Lattice" / "gcfw.basasm", ec);
                std::filesystem::remove(
                    gcfwData / "Bezel Mod Loader" / "Lattice" / "gcfw-clean.basasm", ec);
                std::filesystem::remove(
                    gcfwData / "Bezel Mod Loader" / "Lattice" / "game.basasm", ec);
                std::filesystem::remove(
                    gcfwData / "Bezel Mod Loader" / "Lattice" / "game-clean.basasm", ec);

                // In case tools are updated
                std::filesystem::remove_all(gcfwData / "Bezel Mod Loader" / "tools", ec);
            }
            catch (std::filesystem::filesystem_error& e)
            {
                waitExit("Could not remove previous Bezel's temporary files from application "
                         "storage directory.",
                    e.code().value());
            }
        }
    }
    else
    {
        waitExit("Could not locate %APPDATA%.", -1);
    }

    std::filesystem::remove("gcfw-modded.swf", ec);
    std::filesystem::remove(moddedPath, ec);
    std::filesystem::remove(oldBezelLibrary, ec);
    std::filesystem::remove(oldBezelFile, ec);
    std::filesystem::create_directory("Mods", ec);

    if (ec)
    {
        waitExit("Could not create directory for mods. No changes have been made.", ec.value());
    }

    std::filesystem::create_directory("Bezel", ec);

    if (ec)
    {
        waitExit("Could not create directory for Bezel. No changes have been made.", ec.value());
    }

    FILE* outFile = _wfopen(bezelFile.generic_wstring().c_str(), L"wb");
    fwrite(swfData, 1, swfSize, outFile);
    fclose(outFile);

    if (_wgetenv(L"BezelLibs"))
    {
        const std::filesystem::path bezelLibs{_wgetenv(L"BezelLibs")};

        ec.clear();
        if (!std::filesystem::exists(bezelLibs))
        {
            std::filesystem::create_directories(bezelLibs, ec);
        }

        if (ec)
        {
            printf("Could not create BezelLibs with error code %i\n", ec.value());
        }
        else
        {
            const std::filesystem::path bezelLibrary = bezelLibs / "BezelModLoader.swc";
            outFile = _wfopen(bezelLibrary.generic_wstring().c_str(), L"wb");
            fwrite(swcData, 1, swcSize, outFile);
            fclose(outFile);

            const std::filesystem::path aneLibrary = bezelLibs / "ANEBytecodeEditor.swc";
            outFile = _wfopen(aneLibrary.generic_wstring().c_str(), L"wb");
            fwrite(aneSwcData, 1, aneSwcSize, outFile);
            fclose(outFile);
        }
    }

    if (contentName == "GemCraft Frostborn Wrath.swf")
    {
        printf("Found GemCraft Frostborn Wrath. Exporting its MainLoader\n");
        outFile = _wfopen(mainLoaderPath.generic_wstring().c_str(), L"wb");
        fwrite(gcfwLoaderData, 1, gcfwLoaderSize, outFile);
        fclose(outFile);
    }
    else if (contentName == "gc-cs-steam.swf")
    {
        printf("Found GemCraft Chasing Shadows. Exporting its MainLoader\n");
        outFile = _wfopen(mainLoaderPath.generic_wstring().c_str(), L"wb");
        fwrite(gccsLoaderData, 1, gccsLoaderSize, outFile);
        fclose(outFile);
    }

    {
        zip_t* aneZIP = zip_open_from_source(
            zip_source_buffer_create(aneData, aneSize, 0, nullptr), ZIP_RDONLY, nullptr);
        auto entries = zip_get_num_entries(aneZIP, 0);
        const std::filesystem::path extensionFolder(
            "META-INF/AIR/extensions/com.cff.anebe.ANEBytecodeEditor");
        for (decltype(entries) i = 0; i < entries; i++)
        {
            const std::filesystem::path writeoutName = extensionFolder / zip_get_name(aneZIP, i, 0);
            std::filesystem::create_directories(writeoutName.parent_path(), ec);
            if (ec)
            {
                waitExit("Could not create subdirectory for bytecode editor ANE", ec.value());
            }
            zip_stat_t stat;
            if (zip_stat_index(aneZIP, i, 0, &stat))
            {
                waitExit("Could not stat subfile for bytecode editor ANE",
                    zip_get_error(aneZIP)->zip_err);
            }
            const auto subfileSize = stat.size;
            std::vector<uint8_t> subfileData(subfileSize);
            zip_file_t* subfile = zip_fopen_index(aneZIP, i, 0);
            if (!subfile)
            {
                waitExit("Could not open subfile for bytecode editor ANE",
                    zip_get_error(aneZIP)->zip_err);
            }
            zip_fread(subfile, subfileData.data(), subfileSize);
            zip_fclose(subfile);

            outFile = _wfopen(writeoutName.generic_wstring().c_str(), L"wb");
            fwrite(subfileData.data(), 1, subfileData.size(), outFile);
            fclose(outFile);
        }
    }

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
