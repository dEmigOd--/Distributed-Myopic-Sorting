#pragma once

#include <vector>

namespace Phd
{
	class AbstractParameter
	{
	private:
		size_t count, total;
	protected:
		unsigned min, step, value;

		void OnOperator_plusplus()
		{
			++count;
		}
	public:
		AbstractParameter(unsigned min, size_t total_count, unsigned step)
			: count(0)
			, total(total_count)
			, min(min)
			, step(step)
			, value(min)
		{}

		virtual ~AbstractParameter()
		{
		}

		virtual AbstractParameter& operator ++() = 0;

		unsigned operator*() const
		{
			return value;
		}

		void reset()
		{
			value = min;
			count = 0;
		}

		bool end() const
		{
			return count >= total;
		}

		size_t Total() const
		{
			return total;
		}

		size_t Index() const
		{
			return count;
		}
	};

	class AddParameter : public AbstractParameter
	{
	public:
		AddParameter(unsigned min, size_t total_count, unsigned step)
			: AbstractParameter(min, total_count, step)
		{}

		virtual AbstractParameter& operator ++() override
		{
			OnOperator_plusplus();
			value += step;

			return *this;
		}
	};

	class MultiplyParameter : public AbstractParameter
	{
	public:
		MultiplyParameter(unsigned min, size_t total_count, unsigned step)
			: AbstractParameter(min, total_count, step)
		{
		}

		virtual AbstractParameter& operator ++() override
		{
			OnOperator_plusplus();
			value *= step;

			return *this;
		}
	};

	class Parameter : public AddParameter
	{
	public:
		Parameter(unsigned value)
			: AddParameter(value, value, 1u)
		{}
	};

	class NullParameter : public Parameter
	{
	public:
		NullParameter()
			: Parameter(0)
		{}
	};

	class Parameters
	{
		std::vector<std::shared_ptr<AbstractParameter>> params;
		
		enum ENTRY
		{
			N0,
			COLS,
			ROWS,
			N1,
		};
	public:
		Parameters(const std::vector<std::shared_ptr<AbstractParameter>>& params)
			: params(params)
		{
			if (params.size() != 4)
				throw new std::runtime_error("Not enough parameters supplied");
		}

		AbstractParameter& k() const
		{
			return *params[N0];
		}

		AbstractParameter& m() const
		{
			return *params[COLS];
		}

		AbstractParameter& n() const
		{
			return *params[ROWS];
		}

		AbstractParameter& ones() const
		{
			return *params[N1];
		}
	};
}
