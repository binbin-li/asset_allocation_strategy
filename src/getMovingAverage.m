function [result] = getMovingAverage(data, days)
	result = data;

	total_days = size(data);
	for today = days : total_days
		result(today) = mean(data(today-days+1 : today));
	end
end