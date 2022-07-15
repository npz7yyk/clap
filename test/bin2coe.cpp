#include <fmt/core.h>
#include <fstream>
#include <filesystem>

int main(int argc,char **argv)
{
    auto fin = std::ifstream(argv[1]);
    fmt::print("memory_initialization_radix=16;\nmemory_initialization_vector=");
    while(true)
    {
        char buf[4];
        fin.read(buf,4);
        if(!fin) break;
        fmt::print("\n{:08x}",reinterpret_cast<uint32_t&>(buf));
    }
    fmt::print(";\n");
}
