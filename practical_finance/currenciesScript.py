import requests
import pandas as pd

currencies = pd.read_csv('/Users/franciscotacora/Desktop/books/MasteringShiny/practical/practical_finance/currency_list.csv')
currencies = list(currencies.currency)

my_key = "aBFs7fBsXUX3RQSUVs4CKS5gDdNWRa&"
path_url = 'https://www.amdoren.com/api/currency.php?api_key='
usdPrice = {}

for i in currencies:
    url_price = path_url + my_key + 'from=' + i + '&to=USD'
    currencyValue = requests.get(url_price).json()
    usdPrice[i] = currencyValue['amount']
    
print(usdPrice)
