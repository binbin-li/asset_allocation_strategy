function [coe, stock_weight, bond_weight, stock_w, bond_w, port_parity] = calculateStrategyRisk(duration, start_date, coe, stock_weight, bond_weight, stock_w, bond_w, port_parity, max_days)
    for day = start_date:min(start_date-1+duration, max_days)
        coe(day) = coe(start_date);
        stock_weight(day) = stock_weight(start_date);
        bond_weight(day) = bond_weight(start_date);
        stock_w(day) = stock_w(start_date);
        bond_w(day) = bond_w(start_date);
        port_parity(day,6) = stock_w(day)*port_parity(day,4) + bond_w(day)*port_parity(day,5);
    end
end