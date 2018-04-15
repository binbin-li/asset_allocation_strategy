clear;
%% 读取数据;
data=xlsread('../data/data.xls','hs300_5yearbond');
%计算总天数（样本数）;
totalDays=size(data,1);
%时间日期序列不变，数据从2009年1月5日开始，股票和债券指数根据初始值变为1;
for col=1:3
	price(:,col) = data(128:totalDays, col);
end

%% calculate price from 2009/01/05
price(:,4) = data(128:totalDays,4) / data(128,4);
price(:,5) = data(128:totalDays,5) / data(128,5);
days_since_2009_01_05 = size(price,1);

%% 二、构造40/60组合，月度调仓
%% 2.1调用股票和债券的price数据
port_4060 = price;
port_4060 = [port_4060 zeros(days_since_2009_01_05, 1)];

%% 2.2构造初始组合，买了0.4单位的股票和0.6单位的债券，每个月调仓后的20个交易日内，组合净值等于40%股票价格+60%*债券价格
stock_w = zeros(days_since_2009_01_05,1);%股票数序列
bond_w = zeros(days_since_2009_01_05,1);%债券数序列
 
%第一个月月初股票数和债券数
stock_w(1) = 0.4;
bond_w(1) = 0.6;
[stock_w, bond_w, port_4060] = calculateCombinationValue(20, 1, stock_w, bond_w, port_4060, days_since_2009_01_05);

%% 2.3循环重复上述步骤
for k = 1:floor(days_since_2009_01_05/20)
	start_date = k*20 + 1;
	%月末调仓时，重新平衡，使得股票和债券的资金比重分别为0.4和0.6，计算二者的购买单位;
	stock_w(start_date) = 0.4*port_4060(k*20,6)/port_4060(start_date,4);
	bond_w(start_date) = 0.6*port_4060(k*20,6)/port_4060(start_date,5);
	%计算每天的组合净值;
	[stock_w, bond_w, port_4060] = calculateCombinationValue(20, start_date, stock_w, bond_w, port_4060, days_since_2009_01_05);
end

%% 2.4 40/60组合的评价;
%% 计算组合收益率;
return_rate = zeros(days_since_2009_01_05,1);
port = port_4060(:,6);
for day = 2:days_since_2009_01_05
   return_rate(day) = port(day)/port(day-1) - 1;
end

%计算组合的累计收益率、年化收益率、年化波动率%
accumulative_return_rate = port(days_since_2009_01_05)/port(1) - 1;
annual_yield = (port(days_since_2009_01_05)/port(1)-1)/days_since_2009_01_05*250;
annual_volatility = std(return_rate)*sqrt(250);
%计算组合的最大回撤;
draw = zeros(days_since_2009_01_05,1);
for day = 2:days_since_2009_01_05
	draw(day) = 1 - port(day)/max(port(1:day));
end
max_draw = max(draw);

%% 2.5 画股票、债券、40/60组合走势图
day = 1:days_since_2009_01_05;
stock = port_4060(:,4);
bond = port_4060(:,5);
port4060 = port_4060(:,6);
plot(day,stock,day,bond,day,port4060);

