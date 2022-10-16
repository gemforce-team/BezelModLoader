use std::{io::Cursor, path::Path};

use zip::result::ZipError;

enum ErrorCode {
    NoAppdataFolder,
    NoMetadata,
    NoOpenMetadata(std::io::Error),
    NoParseMetadata(xml_doc::Error),
    NoAppdata,
    CouldNotOpenZip(ZipError),
    CouldNotBackupMetadata(std::io::Error),
    InvalidMetadataXML,
    ContentDoesNotExist,
    CouldntMakeDir(std::io::Error),
    CouldntWriteBezel(std::io::Error),
    CouldntWriteGame(std::io::Error),
    CouldNotExtractZip(ZipError),
}

impl std::fmt::Display for ErrorCode {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self {
            Self::NoAppdataFolder => write!(f, "The folder %APPDATA% does not exist"),
            Self::NoMetadata => write!(
                f,
                "No metadata file. Are you sure this is the game's install location?"
            ),
            Self::NoOpenMetadata(e) => write!(f, "Could not open metadata file: {}", e),
            Self::NoParseMetadata(e) => write!(f, "Could not parse metadata file: {:?}", e),
            Self::NoAppdata => write!(f, "The variable %APPDATA% does not exist"),

            Self::CouldNotOpenZip(e) => write!(f, "Could not open ANE ZIP: {}", e),
            Self::CouldNotBackupMetadata(e) => write!(f, "Could not back up metadata file: {}", e),
            Self::InvalidMetadataXML => {
                write!(f, "The metadata file contains corrupt XML data")
            }
            Self::ContentDoesNotExist => {
                write!(f, "The SWF content file does not exist")
            }
            Self::CouldntMakeDir(e) => {
                write!(
                    f,
                    "Could not create directory for mods or Bezel. No changes have been made. Error: {}", e
                )
            }
            Self::CouldntWriteBezel(e) => {
                write!(f, "Could not install required file: {}", e)
            }
            Self::CouldntWriteGame(e) => {
                write!(f, "Could not write the game identifier file: {}", e)
            }
            Self::CouldNotExtractZip(e) => {
                write!(f, "Could not extract ANE ZIP: {}", e)
            }
        }
    }
}

fn sanitize_contents_path(path: &str) -> String {
    let replace_rules = [("%20", " ")];

    let mut ret = path.to_string();

    replace_rules.iter().for_each(|(orig, replacement)| {
        ret = ret.replace(orig, replacement);
    });

    return ret;
}

fn wait_exit<T: std::fmt::Display>(code: Option<T>) -> ! {
    let mut ret_code = 0;
    if let Some(code) = code {
        ret_code = -1;
        println!("Installation failed. This should be run from your GCFW folder, findable through Steam's \"Browse Local Files\". If you are running this in the correct place, please file a bug report.\nError information: \"{}\" (please provide this if you're making a bug report!)", code);
    } else {
        println!("Installation succeeded.");
    }

    println!("Press enter to exit");

    std::io::stdin().read_line(&mut String::new()).ok();

    std::process::exit(ret_code);
}

macro_rules! delete_files_in_folders {
    ($($prefix:expr => [$($file:expr $(=> $ty:ident)?),+$(,)?]),+$(,)?) => {
        $($(delete_files_in_folders!($($ty)? $prefix => $file);)+)+
    };
    (d $prefix:expr => $file:expr) => {
        delete_files_in_folders!(@rundel std::fs::remove_dir_all($prefix.join($file)))
    };
    ($prefix:expr => $file:expr) => {
        delete_files_in_folders!(@rundel std::fs::remove_file($prefix.join($file)))
    };
    (@rundel $del:expr) => {
        if let Err(e) = $del {
            if e.kind() != std::io::ErrorKind::NotFound {
                wait_exit(Some(e));
            }
        }
    }
}

fn main() {
    // All the byte arrays necessary
    let ane = include_bytes!("../ANEBytecodeEditor.ane");
    let ane_swc = include_bytes!("../ANEBytecodeEditor.swc");
    let swf = include_bytes!("../../obj/BezelModLoader.swf");
    let swc = include_bytes!("../../obj/BezelModLoader.swc");
    let gccs_loader = include_bytes!("../../obj/GCCSMainLoader.swf");
    let gcfw_loader = include_bytes!("../../obj/GCFWMainLoader.swf");
    // ANE needs to be extracted from the byte array
    let mut ane = zip::ZipArchive::new(Cursor::new(ane))
        .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldNotOpenZip(e))));

    let metadata_folder = Path::new("META-INF/AIR");

    let metadata = metadata_folder.join("application.xml");

    if !metadata.is_file() {
        wait_exit(Some(ErrorCode::NoMetadata));
    }

    if !metadata.with_extension("xml.bkp").exists() {
        std::fs::copy(metadata.as_path(), metadata.with_extension("xml.bkp"))
            .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldNotBackupMetadata(e))));
    }

    // Deserialize metadata from the backup that was either just made or made some time ago

    let mut metadata = xml_doc::Document::parse_str(
        &std::fs::read_to_string(metadata.with_extension("xml.bkp"))
            .unwrap_or_else(|e| wait_exit(Some(ErrorCode::NoOpenMetadata(e)))),
    )
    .unwrap_or_else(|e| wait_exit(Some(ErrorCode::NoParseMetadata(e))));

    let game_id = metadata
        .root_element()
        .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)))
        .find(&metadata, "id")
        .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)))
        .text_content(&metadata);
    let game_content = sanitize_contents_path(
        &metadata
            .root_element()
            .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)))
            .find(&metadata, "initialWindow")
            .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)))
            .find(&metadata, "content")
            .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)))
            .text_content(&metadata),
    );
    let game_content_path = Path::new(&game_content).to_owned();
    if !game_content_path.is_file() {
        wait_exit(Some(ErrorCode::ContentDoesNotExist))
    }

    let modded_game_content =
        game_content_path.with_file_name(game_content_path.file_stem().unwrap().to_str().unwrap());
    metadata
        .root_element()
        .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)))
        .find(&metadata, "initialWindow")
        .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)))
        .find(&metadata, "content")
        .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)))
        .set_text_content(&mut metadata, "Bezel/BezelModLoader.swf");

    let extension_element = metadata
        .root_element()
        .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)))
        .find(&metadata, "extensions")
        .unwrap_or_else(|| wait_exit(Some(ErrorCode::InvalidMetadataXML)));

    xml_doc::Element::build(&mut metadata, "extensionID")
        .text_content("com.cff.anebe.ANEBytecodeEditor")
        .push_to(extension_element);

    let appdata = Path::new(
        &std::env::var("APPDATA").unwrap_or_else(|_| wait_exit(Some(ErrorCode::NoAppdata))),
    )
    .to_owned();

    if !appdata.is_dir() {
        wait_exit(Some(ErrorCode::NoAppdataFolder));
    }

    let gcfw_data = appdata.join(game_id).join("Local Store");

    // If the game data folder doesn't exist, we don't need to remove any previous versions' data
    if gcfw_data.is_dir() {
        let bezel_folder = gcfw_data.join("Bezel Mod Loader");
        let lattice_folder = bezel_folder.join("Lattice");

        // This macro deletes and ignores

        delete_files_in_folders!(
            gcfw_data => [
                "coremods.bzl",
                "coremods.lttc",
                "gcfw.basasm",
                "gcfw-clean.basasm",
            ],
            bezel_folder => [
                "coremods.bzl",
                "tools" => d,
            ],
            lattice_folder => [
                "coremods.lttc",
                "gcfw.basasm",
                "gcfw-clean.basasm",
                "game.basasm",
                "game-clean.basasm",
            ],
        );
    }

    delete_files_in_folders!(
        Path::new(".") => [
            "gcfw-modded.swf",
            &modded_game_content,
            "Mods/BezelModLoader.swf",
            "Mods/BezelModLoader.swc"
        ]
    );

    if !Path::new("Mods").exists() {
        std::fs::create_dir("Mods")
            .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldntMakeDir(e))));
    }
    if !Path::new("Bezel").exists() {
        std::fs::create_dir("Bezel")
            .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldntMakeDir(e))));
    }

    std::fs::write("Bezel/BezelModLoader.swf", swf)
        .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldntWriteBezel(e))));

    std::fs::write("game-file.txt", game_content)
        .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldntWriteGame(e))));

    if let Some(bezel_libs) = std::env::var_os("BezelLibs") {
        let bezel_libs = Path::new(&bezel_libs);
        if !bezel_libs.exists() {
            if let Err(e) = std::fs::create_dir(bezel_libs) {
                println!(
                    "Could not make bezel library folder at {}; error was {}",
                    bezel_libs.as_os_str().to_string_lossy(),
                    e
                );
            } else {
                std::fs::write(bezel_libs.join("BezelModLoader.swc"), swc)
                    .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldntWriteBezel(e))));
                std::fs::write(bezel_libs.join("ANEBytecodeEditor.swc"), ane_swc)
                    .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldntWriteBezel(e))));
            }
        }
    }

    if game_content_path == Path::new("GemCraft Frostborn Wrath.swf") {
        println!("Found GemCraft Frostborn Wrath. Exporting its MainLoader");
        std::fs::write("Bezel/MainLoader.swf", gcfw_loader)
            .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldntWriteBezel(e))));
    } else if game_content_path == Path::new("gc-cs-steam.swf") {
        println!("Found GemCraft Chasing Shadows. Exporting its MainLoader");
        std::fs::write("Bezel/MainLoader.swf", gccs_loader)
            .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldntWriteBezel(e))));
    }

    ane.extract(metadata_folder.join("extensions/com.cff.anebe.ANEBytecodeEditor"))
        .unwrap_or_else(|e| wait_exit(Some(ErrorCode::CouldNotExtractZip(e))));

    std::fs::write(
        metadata_folder.join("application.xml"),
        metadata
            .write_str()
            .unwrap_or_else(|e| wait_exit(Some(ErrorCode::NoParseMetadata(e)))),
    )
    .unwrap_or_else(|e| wait_exit(Some(ErrorCode::NoOpenMetadata(e))));

    wait_exit::<&str>(None);
}
