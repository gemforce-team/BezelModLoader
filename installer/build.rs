#[cfg(windows)]
use registry::{Hive, Security};
#[cfg(windows)]
use std::io::Error;
#[cfg(windows)]
use std::process::Command;
#[cfg(windows)]
use std::{env, str};

#[cfg(windows)]
fn main() -> Result<(), i32> {
    println!("cargo:rerun-if-changed=../src");
    println!("cargo:rerun-if-changed=../Bezel.as3proj");
    println!("cargo:rerun-if-changed=../BezelLibrary.as3proj");
    println!("cargo:rerun-if-changed=../GCCSMainLoader.as3proj");
    println!("cargo:rerun-if-changed=../GCFWMainLoader.as3proj");
    println!("cargo:rerun-if-env-changed=AIRSDK");

    println!("{:?}", env::vars().collect::<Vec<(String, String)>>());

    let deps = [
        ("../obj/BezelModLoader.swf", "../src", "../Bezel.as3proj"),
        ("../obj/BezelModLoader.swc", "../src", "../Bezel.as3proj"),
        (
            "../obj/GCCSMainLoader.swf",
            "../src/Bezel/GCCS",
            "../GCCSMainLoader.as3proj",
        ),
        (
            "../obj/GCFWMainLoader.swf",
            "../src/Bezel/GCFW",
            "../GCFWMainLoader.as3proj",
        ),
    ];

    let mut needs_recompile = [false, false, false, false];

    for i in 0..4 {
        let (dep, src, build_file) = deps[i];

        match check_times(&dep, &src, &build_file) {
            Ok(needs_it) => needs_recompile[i] = needs_it,
            Err(err) => {
                eprintln!("I/O error occurred while looking for changes: {}", err);
                return Err(3);
            }
        };
    }

    if needs_recompile[0]
        || needs_recompile[1]
        || (!needs_recompile[0]
            && !needs_recompile[1]
            && !needs_recompile[2]
            && !needs_recompile[3])
    {
        return do_build(deps[0].2);
    } else {
        if needs_recompile[2] && needs_recompile[3] {
            return do_build("../BothMainLoaders.as3proj");
        } else if needs_recompile[2] {
            return do_build(deps[2].2);
        } else if needs_recompile[3] {
            return do_build(deps[3].2);
        }
    }

    return Ok(());
}

#[cfg(windows)]
fn check_times(dep: &str, src: &str, builder: &str) -> Result<bool, Error> {
    let dep_time = std::fs::metadata(dep)?.modified()?;

    if std::fs::metadata(builder)?.modified()? > dep_time {
        return Ok(true);
    }

    for file in walkdir::WalkDir::new(src) {
        let file = file?;
        if file.metadata()?.is_dir()
            || file.path().ancestors().any(|f| {
                (!src.ends_with("GCFW") && f.ends_with("GCFW"))
                    || (!src.ends_with("GCCS") && f.ends_with("GCCS"))
            })
        {
            continue;
        }

        if file.metadata()?.modified()? > dep_time {
            return Ok(true);
        }
    }

    return Ok(false);
}

#[cfg(windows)]
fn do_build(build_file: &str) -> Result<(), i32> {
    let flashdevelop = Hive::LocalMachine.open("SOFTWARE\\FlashDevelop", Security::Read);
    if flashdevelop.is_err() {
        eprintln!("FlashDevelop not installed");
        return Err(1);
    }
    let flashdevelop = flashdevelop.unwrap().value("").unwrap().to_string();

    println!("FlashDevelop found at {}", &flashdevelop);

    let airsdk = env::var("AIRSDK");
    if airsdk.is_err() {
        eprintln!("Air SDK not found in environment variables. Try setting AIRSDK.");
        return Err(2);
    }
    let airsdk = airsdk.unwrap();

    println!("Using AIR SDK {}", airsdk);

    let output = Command::new(flashdevelop.clone() + "/Tools/fdbuild/fdbuild.exe")
        .args([
            build_file,
            "-compiler",
            &airsdk,
            #[cfg(release)]
            "-notrace",
            "-target",
            "",
        ])
        .output()
        .unwrap();

    if output.status.success() {
        return Ok(());
    } else {
        eprintln!("{}", str::from_utf8(&output.stdout).unwrap());
        eprintln!("{}", str::from_utf8(&output.stderr).unwrap());
        return Err(output.status.code().unwrap());
    }
}

#[cfg(not(windows))]
fn main() {}
