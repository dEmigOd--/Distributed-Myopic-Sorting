#pragma once

#include <iostream>
#include <bitset>

namespace Phd
{
	template<size_t sz>
	bool operator<(const std::bitset<sz>& x, const std::bitset<sz>& y)
	{
		for (int i = sz - 1; i >= 0; i--)
		{
			if (x[i] ^ y[i]) return y[i];
		}
		return false;
	}

	template<size_t sz>
	std::ostream& operator << (std::ostream& out, const std::tuple<Type, std::vector<Item>, std::bitset<sz>>& lhs)
	{
		out << "(" << static_cast<int>(std::get<0>(lhs)) << ", [" << static_cast<int>(*std::get<1>(lhs).begin());
		for (int i = 1; i < std::get<1>(lhs).size(); ++i)
			out << ", " << static_cast<int>(std::get<1>(lhs)[i]);
		out << "], " << std::get<2>(lhs).to_ulong() << ")";
		return out;
	}

	template<size_t sz> struct input_tuple_comparer
	{
		bool operator() (const std::tuple<Type, std::vector<Item>, std::bitset<sz>>& lhs, const std::tuple<Type, std::vector<Item>, std::bitset<sz>>& rhs) const
		{
			if (std::get<0>(lhs) < std::get<0>(rhs))
				return true;
			if (std::get<0>(rhs) < std::get<0>(lhs))
				return false;

			if (std::get<1>(lhs) < std::get<1>(rhs))
				return true;
			if (std::get<1>(rhs) < std::get<1>(lhs))
				return false;

			return (std::get<2>(lhs) < std::get<2>(rhs));
		}
	};
}
