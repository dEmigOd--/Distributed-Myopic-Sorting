#pragma once

#include <vector>
#include <memory>
#include <iostream>
#include "Enums.h"
#include "Algorithm.h"

namespace Phd
{
	class Agent
	{
	protected:
		Type type;
		unsigned memory;
		std::shared_ptr<Algorithm> f;

	public:
		Agent(Type type, std::shared_ptr<Algorithm> f)
			: type(type)
			, memory()
			, f(f)
		{
		}

		Direction LookComputeMove(const std::vector<Item>& neighborhood)
		{
			auto decision = f->Step(type, memory, neighborhood);
			memory = std::get<0>(decision);

			return std::get<1>(decision);
		}

		Type Type() const
		{
			return type;
		}

		std::ostream& Print(std::ostream& out) const
		{
			switch (type)
			{
				case Type::EXIT:
					out << char(0xB1);			break;
				case Type::EXPERIMENTAL:
					out << char(0xDB);			break;
				case Type::CONTINUE:
					out << char(0xB2);			break;
				default:
					break;
			}

			return out;
		}
	};

	std::ostream& operator<< (std::ostream& out, const Agent& agent)
	{
		return agent.Print(out);
	}
}
