// ProcessMatlabGraphs.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <array>
#include <iostream>
#include <fstream>
#include <string>
#include <filesystem>

void ReplaceSubstring(std::string& str, const std::string& what, const std::string& with)
{
    std::string::size_type n = 0;
    while ((n = str.find(what, n)) != std::string::npos)
    {
        str.replace(n, what.size(), with);
        n += with.size();
    }
}

void RemoveArtefacts(std::string& str, const std::string& prefix)
{
    std::string label = str.substr(prefix.length() + 1, str.rfind("}", str.length()) - (prefix.length() + 1));
    ReplaceSubstring(label, "{", "");
    ReplaceSubstring(label, "\\text", "");
    ReplaceSubstring(label, "}", "");
    str.replace(prefix.length() + 1, str.rfind("}", str.length()) - (prefix.length() + 1), label);
}

void UpdateTexFile(const std::filesystem::directory_entry& entry)
{
    std::array<std::string, 12> marks =
    {
        "*",
        "square",
        "oplus",
        "diamond*",
        "halfsquare left*",
        "otimes",
        "asterisk",
        "star",
        "triangle*",
        "halfdiamond",
        "halfcircle*",
        "pentagon*",
    };
    size_t usedMarks = 0;

    std::ifstream ifile(entry);
    std::ofstream ofile(entry.path().parent_path() / L"Processed" / entry.path().filename());

    std::string line;
    while (!ifile.eof())
    {
        std::getline(ifile, line);

        if (line.rfind("title=", 0) != std::string::npos)
        {
            ofile << "% " << line << '\n';
            continue;
        }

        //if ((line.rfind("xlabel=", 0) != std::string::npos) ||
        //    (line.rfind("ylabel=", 0) != std::string::npos))
        //{
        //    RemoveArtefacts(line, "?label=");
        //}

        //if (line.rfind("\\addlegendentry", 0) != std::string::npos)
        //{
        //    RemoveArtefacts(line, "\\addlegendentry");
        //}

        if (line.rfind("\\addplot", 0) != std::string::npos)
        {
            std::string::size_type markStart = line.find("mark=");
            if (markStart != std::string::npos)
            {
                std::string::size_type nextComma = line.find(",", markStart);
                ReplaceSubstring(line, line.substr(markStart + 5, nextComma - markStart - 5), marks[usedMarks++]);               
            }
            else
            {
                if (line.find("forget plot") == std::string::npos)
                {
                    line.replace(line.rfind("]", line.length()), 0, std::string(", mark=") + marks[usedMarks++]);
                }
            }            
        }


        ofile << line << '\n';
    }
}

int main()
{
    std::filesystem::path workDir("../../Algorithm310xSeries/Algorithm310xSeries/Data/");
    std::wstring ext(L".tex");
    std::wstring special_name(L".319");

    for (const auto& entry : std::filesystem::directory_iterator(workDir))
    {
        if ((entry.path().extension() == ext) && (entry.path().filename().wstring().find(special_name) != std::wstring::npos))
        {
            UpdateTexFile(entry);
        }
    }

    return 0;
}

