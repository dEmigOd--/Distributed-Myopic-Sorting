#pragma once

#include <iostream>
#include <string>
#include <stdexcept>
#include <vector>
#include "mat.h"

class MatlabPrinter
{
    std::string filename;
	MATFile* pmat;

    class ArrayWrapper
    {
    private:
        mxArray* parr;
    public:
        ArrayWrapper(mxArray* parr)
            : parr(parr)
        {
            if (parr == NULL)
            {
                std::cerr << __FILE__ << " : Out of memory on line " << __LINE__ << ".\n";
                std::cerr << "Unable to create mxArray.\n";
                throw std::runtime_error("Memory allocation failure");
            }
        }

        ArrayWrapper(size_t rows, size_t columns)
            : ArrayWrapper(mxCreateDoubleMatrix(rows, columns, mxREAL))
        {
        }
        
        mxArray* operator *() const
        {
            return parr;
        }

        ~ArrayWrapper()
        {
            mxDestroyArray(parr);
        }
    };

    void WriteVariable(const std::string& varName, const ArrayWrapper& parr) const
    {
        auto status = matPutVariable(pmat, varName.c_str(), *parr);
        if (status != 0)
        {
            std::cerr << __FILE__ << " : Error using matPutVariable on line " << __LINE__ << ".\n";
            std::cerr << "Failed to write mxArray.\n";
            throw std::runtime_error("Write operation failure");
        }
    }

    void WriteArray(const std::string& varName, const std::vector<double>& data, size_t rows, size_t cols) const
    {
        auto parr = ArrayWrapper(rows, cols);

        memcpy(reinterpret_cast<void*>(mxGetPr(*parr)), reinterpret_cast<const void*>(data.data()), sizeof(double) * data.size());

        WriteVariable(varName, parr);
    }


public:
	MatlabPrinter(const std::string& filename)
        : filename(filename)
	{ 
        pmat = matOpen(filename.c_str(), "w");
        if (pmat == NULL)
        {
            std::cerr << "Error creating file " << filename << ".\n";
            std::cerr << "(Do you have write permission in this directory?)\n";
            throw std::runtime_error("Unable to create a file");
        }
    }

    virtual ~MatlabPrinter()
    {
        if (matClose(pmat) != 0)
        {
            std::cerr << "Error closing file " << filename << ".\n";
        }
    }

    void WriteArray(const std::string& varName, const std::vector<double>& data) const
    {
        WriteArray(varName, data, data.size(), 1);
    }

    template<typename T>
    void WriteArray(const std::string& varName, const std::vector<std::vector<T>>& data) const
    {
        std::vector<double> accum;
        for (auto& row : data)
            accum.insert(std::end(accum), std::begin(row), std::end(row));
        WriteArray(varName, accum, data[0].size(), data.size());
    }

    template<typename T>
    void WriteArray(const std::string& varName, const std::vector<T>& data) const
    {
        std::vector<double> copy(data.cbegin(), data.cend());
        WriteArray(varName, copy);
    }

    void WriteScalar(const std::string& varName, const std::string& data) const
    {
        auto parr = ArrayWrapper(mxCreateString(data.c_str()));

        WriteVariable(varName, parr);
    }
    
    template<typename T>
    void WriteScalar(const std::string& varName, const T& data) const
    {
        std::vector<T> arr(1, data);
        WriteArray(varName, arr);
    }
};
