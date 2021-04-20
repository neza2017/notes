file_name="沪深300指数历史数据.csv"
#file_name="test.csv"

def goo(a,b):
    if a==0:
        return 0
    else:
        return(b-a)/a

def foo(period, history_data):
    value=[]
    idx=0
    while idx<period-1:
        value.append((history_data[idx][0],history_data[idx][1],0,0))
        idx=idx+1
    value.append((history_data[idx][0],history_data[idx][1],period,period))
    
    while idx+1<len(history_data):
        idx=idx+1
        date = history_data[idx][0]
        price = history_data[idx][1]
        last_price = value[-1][1]
        last_input = value[-1][2]
        last_value = value[-1][3]
        last_value = price/last_price * last_value
        if (idx+1)%period == 0:
            last_input = last_input + period
            last_value = last_value + period
        value.append((date,price,last_input,last_value))
    return value


fp=open(file_name)
file_head=fp.readline()

history_data=[]

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
    
    history_data.insert(0,(date,price))
    
    line_data=fp.readline()

value1 = foo(1,history_data)
value2 = foo(2,history_data)
value5 = foo(5,history_data)
value10 = foo(10,history_data)
value20 = foo(20,history_data)
value30 = foo(30,history_data)

# print("日期,沪深300指数",end=",")
# print("1日投成本,1日投资产,1日投收益率",end=",")
# print("2日投成本,2日投资产,2日投收益率",end=",")
# print("5日投成本,5日投资产,5日投收益率",end=",")
# print("10日投成本,10日投资产,10日投收益率",end=",")
# print("20日投成本,20日投资产,20日投收益率",end=",")
# print("30日投成本,30日投资产,30日投收益率")

idx=0
while idx<len(history_data):
    # print(history_data[idx][0],history_data[idx][1],sep=",",end=",")
    print(value1[idx][2],value1[idx][3],goo(value1[idx][2],value1[idx][3]),sep=",",end=",")
    print(value2[idx][2],value2[idx][3],goo(value2[idx][2],value2[idx][3]),sep=",",end=",")
    print(value5[idx][2],value5[idx][3],goo(value5[idx][2],value5[idx][3]),sep=",",end=",")
    print(value10[idx][2],value10[idx][3],goo(value10[idx][2],value10[idx][3]),sep=",",end=",")
    print(value20[idx][2],value20[idx][3],goo(value20[idx][2],value20[idx][3]),sep=",",end=",")
    print(value30[idx][2],value30[idx][3],goo(value30[idx][2],value30[idx][3]),sep=",")
    idx=idx+1