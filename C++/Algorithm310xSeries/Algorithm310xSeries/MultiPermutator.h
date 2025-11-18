#pragma once

#include <vector>
#include <set>

namespace Phd
{
	class DuPermutator
	{
	private:
		int n;
		int k1, k2;

		std::vector<int> perm1, perm2, lookup;

		static bool GetNextPermutation(int n, std::vector<int>& perm)
		{
			auto lastchange = perm.size();
			for (auto i = 0; i < perm.size(); ++i)
			{
				if (perm[i] < n - i)
				{
					lastchange = i;
					break;
				}
			}
			if (lastchange == perm.size())
				return false;

			++perm[lastchange];
			for (auto i = lastchange; i > 0; --i)
				perm[i - 1] = perm[i] + 1;

			return true;
		}

		static std::vector<int> InitPermutation(int n)
		{
			std::vector<int> result(n, 0);
			for (auto i = 0; i < result.size(); ++i)
				result[i] = n - i;
			return result;
		}

		static std::vector<int> GetTheRest(int n, const std::vector<int>& inds)
		{
			std::set<int> values(inds.begin(), inds.end());
			std::vector<int> result;
			result.reserve(n - inds.size());

			for (auto i = n; i > 0; --i)
			{
				if(values.find(i) == values.end())
					result.push_back(i);
			}
			std::reverse(result.begin(), result.end());
			return result;
		}

		static std::vector<int> GetLookupValues(const std::vector<int>& lookup, const std::vector<int>& indices)
		{
			std::vector<int> result(indices.size(), 0);
			for (auto i = 0; i < result.size(); ++i)
				result[i] = lookup[indices[i] - 1ull];
			return result;
		}
	public:
		DuPermutator(int n, int k1, int k2)
			: n(n)
			, k1(k1)
			, k2(k2)
		{
			perm1 = InitPermutation(k1);
			perm2 = InitPermutation(k2);
			lookup = GetTheRest(n, perm1);
		}

		std::tuple<std::vector<int>, std::vector<int>> GetPermutation() const
		{
			return std::make_tuple(perm1, GetLookupValues(lookup, perm2));
		}

		bool NextPermutation()
		{
			if (!GetNextPermutation(n - k1, perm2))
			{
				if (!GetNextPermutation(n, perm1))
					return false;
				lookup = GetTheRest(n, perm1);
				perm2 = InitPermutation(k2);
			}

			return true;
		}
	};
}
