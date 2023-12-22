#include "encoding.hpp"

std::string Encoding::name() { }

Eigen::VectorXi Encoding::fill_vector_from_samples( const std::vector<int>& samples,
                                                    size_t index_sample,
                                                    size_t number_variables,
                                                    size_t domain_size,
                                                    int starting_value,
                                                    int additional_variable )
{
	std::vector<int> candidate;
	size_t shift = index_sample * ( number_variables + additional_variable );
	std::copy( samples.begin() + shift,
	           samples.begin() + shift + number_variables,
	           std::back_inserter( candidate ) );
	
	return fill_vector( candidate, domain_size, starting_value, additional_variable );
}

Eigen::VectorXd Encoding::fill_vector_reals_from_samples( const std::vector<int>& samples,
                                                          size_t index_sample,
                                                          size_t number_variables,
                                                          size_t domain_size,
                                                          int starting_value,
                                                          int additional_variable )
{
	std::vector<int> candidate;
	size_t shift = index_sample * ( number_variables + additional_variable );
	std::copy( samples.begin() + shift,
	           samples.begin() + shift + number_variables,
	           std::back_inserter( candidate ) );
	
	return fill_vector_reals( candidate, domain_size, starting_value, additional_variable );
}
