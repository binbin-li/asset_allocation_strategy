function [stock_w, bond_w, port_4060] = calculateCombinationValue(duration, start_date, stock_w, bond_w, port_4060, max_days)
	for day = start_date:min(start_date - 1 + duration, max_days)%防止超过样本数;
		stock_w(day) = stock_w(start_date);
		bond_w(day) = bond_w(start_date);
		port_4060(day,6) = stock_w(day)*port_4060(day,4)+bond_w(day)*port_4060(day,5);
	end
end