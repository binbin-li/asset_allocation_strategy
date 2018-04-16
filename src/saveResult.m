function [] = saveResult(stock, bond, value, dates, path)
	data = [dates stock bond value];
	csvwrite(path, data);
end