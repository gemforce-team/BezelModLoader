#include <cstdio>
#include <filesystem>

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        std::fprintf(stderr, "Usage: \'%s <basasm file>\'", argv[0]);
        return -1;
    }

    size_t size = std::filesystem::file_size(argv[1]);
    std::unique_ptr<char[]> data = std::unique_ptr<char[]>(new char[size]);

    FILE *f = fopen(argv[1], "rt");
    fread(data.get(), 1, size, f);
    fclose(f);

    char *current = data.get();
    while (current != data.get() + size)
    {
        std::string filename = current;
        current += filename.size() + 1;
        std::string filecontents = current;
        current += filecontents.size() + 1;

        const std::filesystem::path outfile{"./" + filename};
        const std::filesystem::path outdir = outfile.parent_path();

        std::filesystem::create_directories(outdir);
        f = _wfopen(outfile.generic_wstring().c_str(), L"wt");
        fwrite(filecontents.c_str(), 1, filecontents.size(), f);
        fclose(f);
    }

    return 0;
}
