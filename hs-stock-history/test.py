#file_name="沪深300指数历史数据.csv"
file_name="test.csv"

fp=open(file_name)
file_head=fp.readline()

line_data=fp.readline()
while line_data!="":
    pos = line_data.find("\"",1)
    date = line_data[1:pos-1]

    beg = line_data.find("\"",pos+1)
    end = line_data.find("\"",beg+1)
    price = line_data[beg+1:end-1]
    pos = price.find(",")
    if pos!=-1:
        price = price[0:pos] + price[pos+1:]

    ypos = date.find("年")
    year = date[0:ypos]
    mpos = date.find("月")
    mon = date[ypos+1:mpos]
    day = date[mpos+1:]

    date="{}-{:02d}-{:02d}".format(int(year),int(mon),int(day))
    price=float(price)
    print(date,price)
    
    line_data=fp.readline()
