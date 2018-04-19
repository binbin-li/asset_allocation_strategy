function [coe, stock_weight, bond_weight, stock_w, bond_w, port_parity, signals] = calculateStrategy(duration, start_date, coe, stock_weight, bond_weight, stock_w, bond_w, port_parity, max_days, price, signals, extra_weight)
    for day = start_date : min(start_date-1+duration, max_days)
        coe(day) = coe(start_date);
        last_day = day - 1;

        % Handle cases when day == 1 or day == 2
        if day == 1
            continue;
        elseif day == 2
            stock_weight(day) = stock_weight(last_day);
            bond_weight(day) = bond_weight(last_day);
            stock_w(day) = stock_w(last_day);
            bond_w(day) = bond_w(last_day);
            continue;
    	end

    	if price(last_day, 6) > price(last_day, 7) && price(last_day, 7) > price(last_day, 8) && price(last_day, 8) > price(last_day-1, 8) && price(last_day, 6) > price(last_day-1, 6)
    		signals(day) = 1;
            if signals(last_day) == 0
                stock_weight(day) = stock_weight(start_date) + extra_weight;
                bond_weight(day) = 1 - stock_weight(day);
                stock_w(day) = port_parity(last_day, 6)*stock_weight(day)/port_parity(last_day, 4);
                bond_w(day) = port_parity(last_day, 6)*bond_weight(day)/port_parity(last_day, 5);
            else
                stock_weight(day) = stock_weight(last_day);
                bond_weight(day) = bond_weight(last_day);
                stock_w(day) = stock_w(last_day);
                bond_w(day) = bond_w(last_day);
            end
    	else
            signals(day) = 0;
            if signals(last_day) == 0
                stock_weight(day) = stock_weight(last_day);
                bond_weight(day) = bond_weight(last_day);
                stock_w(day) = stock_w(last_day);
                bond_w(day) = bond_w(last_day);
            else
                stock_weight(day) = stock_weight(start_date);
                bond_weight(day) = 1 - stock_weight(day);
                stock_w(day) = port_parity(last_day, 6)*stock_weight(day)/port_parity(last_day, 4);
                bond_w(day) = port_parity(last_day, 6)*bond_weight(day)/port_parity(last_day, 5);
            end
        end
        port_parity(day,6) = stock_w(day)*port_parity(day,4) + bond_w(day)*port_parity(day,5);
    end
end