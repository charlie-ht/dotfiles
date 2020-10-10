#!/usr/bin/env python3

from datetime import datetime
import calendar
from string import Template
import os
import subprocess

D=os.path.dirname(os.path.realpath(__file__))

invoice_template = Template("""
Date of invoice: $date_of_invoice
Invoice number: $invoice_number

Charlie Turner
54 Harlow Manor Park                    Igalia
Harlow Moor                             Bugallal Marchesi, 22, 1º
Harrogate                               15008 A Coruña
HG2 0HH                                 Galica (Spain)
United Kingdom

VAT: GB 273460600                       VAT: ES B15804842

Account holder: Charles Turner
BIC:            TRWIBEB1XXX
IBAN:           BE72 9670 2001 6116

Start        End         Services                                                Amount          VAT
$start_of_month_date   $end_of_month_date  Software development services for the month of $month_name   $total_invoiced EUR    Zero

Total $total_invoiced EUR
Total VAT - N/A
""")


def next_invoice_number():
    with open(os.path.join(D, 'invoices.db'), 'r') as f:
        number = int(f.read())
        return number + 1

now = datetime.now()
invoice_number = next_invoice_number()

payment = input("Enter the invoice total: ")
payment = float(payment)
telework_help = 64
payment += telework_help


invoice = invoice_template.substitute(
    date_of_invoice=now.strftime('%d/%m/%Y'),
    invoice_number=invoice_number,
    start_of_month_date=f'01/0{now.month}/{now.year}',
    end_of_month_date=f'{calendar.monthrange(now.year, now.month)[1]}/0{now.month}/{now.year}',
    month_name=now.strftime('%B'),
    total_invoiced=payment)

with open(os.path.join(D, 'invoices.db'), 'w') as f:
    f.write(str(invoice_number))

INVOICE_ROOT='/home/cht/Documents/money/invoices/'
little_month = now.strftime('%b').lower()
little_year=now.strftime
invoice_filename = os.path.join(INVOICE_ROOT, now.strftime('%y-%m-%b').lower() + '.txt')
with open(invoice_filename, 'w') as f:
    f.write(invoice)

print(f'wrote invoice to {invoice_filename}')


