clear;
%% 一、读取数据;
data = xlsread('../data/data.xls','hs300_5yearbond');
%计算总天数（样本数）;
total_days = size(data,1);
%从2009年1月5日开始的价格序列;
price = data(128:total_days,:);
price(:,4) = price(:,4)/price(1,4);
price(:,5) = price(:,5)/price(1,5);
days_since_2009_01_05 = size(price,1);

%% 二、构造基础的风险平价组合，月度调仓
%% 2.1净值从2009年1月5日开始
port_parity = zeros(days_since_2009_01_05,6);
for col = 1:5
    port_parity(:,col) = price(:,col);
end

%% 2.2计算股票和债券收益率序列

%% 2008年6月30日开始的收益率序列
return_since_06_30 = zeros(total_days,5);
for col = 1:3
    return_since_06_30(:,col) = data(:,col);
end

for day = 2:total_days
   return_since_06_30(day,4) = data(day,4)/data(day-1,4) - 1;%ret第4列为股票收益率序列
   return_since_06_30(day,5) = data(day,5)/data(day-1,5) - 1;%ret第5列为债券收益率序列
end

%% 2.3估计股债的相关系数和波动率，确定二者权重

%生成波动率、相关系数、股票债券资金权重序列;
coe = zeros(days_since_2009_01_05,1);
stock_vol = zeros(days_since_2009_01_05,1);
bond_vol = zeros(days_since_2009_01_05,1);
stock_weight = zeros(days_since_2009_01_05,1);
bond_weight = zeros(days_since_2009_01_05,1);
 
%计算股票和债券收益率序列的相关系数（2009年1月5日的前120个交易日的数据）;
coe(1) = min(min(corrcoef(return_since_06_30(8:127,4),return_since_06_30(8:127,5))));

%简单移动平均法预测波动率;
stock_vol(1) = std(return_since_06_30(8:127,4))*sqrt(250);
bond_vol(1) = std(return_since_06_30(8:127,5))*sqrt(250);

stock_w = zeros(days_since_2009_01_05,1);
bond_w = zeros(days_since_2009_01_05,1);
stock_weight(1) = (1/stock_vol(1)) / (1/stock_vol(1)+1/bond_vol(1));%计算权重
bond_weight(1) = 1 - stock_weight(1);

stock_w(1) = stock_weight(1) / port_parity(1,4);%计算股票数;
bond_w(1) = bond_weight(1) / port_parity(1,5);%计算债券数;

%计算风险平价策略净值;
[coe, stock_weight, bond_weight, stock_w, bond_w, port_parity] = calculateStrategyRisk(20, 1, coe, stock_weight, bond_weight, stock_w, bond_w, port_parity, days_since_2009_01_05);

%% 2.4 循环重复上述步骤
for k = 1:floor(days_since_2009_01_05/20)
    start_date = 1 + 20*k;
    %计算调仓日前120个交易日的股票和债券收益率序列的相关系数;
    coe(start_date) = min(min(corrcoef(return_since_06_30(8+20*k:127+20*k,4),return_since_06_30(8+20*k:127+20*k,5))));

    %简单移动平均法预测波动率;
    stock_vol(start_date) = std(return_since_06_30(8+20*k:127+20*k,4))*sqrt(250);
    bond_vol(start_date) = std(return_since_06_30(8+20*k:127+20*k,5))*sqrt(250);

    %根据风险平价公式计算股票和债券的资金权重;
    stock_weight(start_date) = (1/stock_vol(start_date))/(1/stock_vol(start_date) + 1/bond_vol(start_date));
    bond_weight(start_date) = 1 - stock_weight(start_date);

    %月末调仓时，重新平衡，使得股票和债券的资金比重分别为stock_weight和bond_weight，计算二者的购买单位;
    stock_w(start_date) = stock_weight(start_date)*port_parity(20*k,6)/port_parity(start_date,4);
    bond_w(start_date) = bond_weight(start_date)*port_parity(20*k,6)/port_parity(start_date,5);

    %计算风险平价策略净值;
    [coe, stock_weight, bond_weight, stock_w, bond_w, port_parity] = calculateStrategyRisk(20, start_date, coe, stock_weight, bond_weight, stock_w, bond_w, port_parity, days_since_2009_01_05);
end
   
%% 三、基础风险平价组合的评价
%% 3.1计算组合收益率
return_port = zeros(days_since_2009_01_05,1);
port = port_parity(:,6);
for day = 2:days_since_2009_01_05
   return_port(day) = port(day)/port(day-1) - 1;
end

%% 3.2计算组合的累计收益率、年化收益率、年化波动率%
accumulative_return = port(days_since_2009_01_05)/port(1)-1;
annual_return = (port(days_since_2009_01_05)/port(1)-1)/days_since_2009_01_05*250;
volatility = std(return_port)*sqrt(250);

%% 3.3计算组合的最大回撤
draw = zeros(days_since_2009_01_05,1);
for day = 2:days_since_2009_01_05
    draw(day) = 1 - port(day)/max(port(1:day));
end
maxdraw = max(draw);

%% 3.4 画股票、债券、基础风险平价组合走势图
day = 1:days_since_2009_01_05;
stock = port_parity(:,4);
bond = port_parity(:,5);
parity = port_parity(:,6);
plot(day,stock,day,bond,day,parity);
saveResult(stock, bond, parity, price(:, 1:3), '../out/parity_result.csv');
