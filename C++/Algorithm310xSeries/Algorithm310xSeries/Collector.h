#pragma once

#include <vector>
#include <iostream>
#include <fstream>
#include "Enums.h"
#include "LLGrid.h"

namespace Phd
{
	class DataCollector
	{
	public:
		virtual void Collect(const LLGrid& grid) = 0;
		virtual std::ostream& Print(std::ostream& out) const = 0;
	};

	std::ostream& operator << (std::ostream& out, const DataCollector& collector)
	{
		return collector.Print(out);
	}

	class ColumnDepicturer : public DataCollector
	{
	private:
		std::vector<std::vector<Item>> data;
		int col;
		int records;
		std::string filename;

	public:
		ColumnDepicturer(int col, int column_size, int length, const std::string& filename = "")
			: data(length, std::vector<Item>(column_size, Item::EMPTY))
			, col(col)
			, records()
			, filename(filename)
		{}

		virtual ~ColumnDepicturer()
		{
			if (!filename.empty())
			{
				std::ofstream out(filename + std::to_string(col) + ".txt");
				out << *this;
			}
		}

		virtual void Collect(const LLGrid& grid) override
		{
			if (records >= data.size())
				return;

			for (int row = 0; row < data[0].size(); ++row)
			{
				data[records][row] = grid(row, col);
			}
			++records;
		}

		virtual std::ostream& Print(std::ostream& out) const override
		{
			char symbol[] = { ' ', 'x', '.', 'o' };

			for (int row = 0; row < data[0].size(); ++row)
			{
				for (int col = 0; col < data.size(); ++col)
				{
					out << symbol[static_cast<int>(data[col][row])];
				}
				out << '\n';
			}

			return out;
		}
	};

	class Collectors : public DataCollector
	{
		std::vector<std::shared_ptr<DataCollector>> collectors;
	public:
		void AddCollector(std::shared_ptr<DataCollector> collector)
		{
			collectors.push_back(collector);
		}

		virtual void Collect(const LLGrid& grid) override
		{
			for (auto collector : collectors)
				collector->Collect(grid);
		}

		virtual std::ostream& Print(std::ostream& out) const
		{
			for (auto collector : collectors)
				out << *collector;
			return out;
		}
	};
}
