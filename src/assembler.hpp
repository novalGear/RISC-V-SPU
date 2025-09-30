#pragma once
//
// std::vector<std::string> parse_string(const std::string& input);
#include <vector>
#include <string>


std::vector<std::string> parseInstruction(const std::string& line);
uint64_t assembleInstruction(std::vector<std::string>);
