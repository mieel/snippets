# Reading an excel file using Python 
import xlrd 


# Get Template Values
# Give the location of the file 
template_loc = ("template.xlsx")
datafile_loc = ("file.xlsx")
  
# To open Workbook 
template_wb = xlrd.open_workbook(template_loc)
datafile_wb = xlrd.open_workbook(datafile_loc)

# Compare Sheet names
template_sheet_names = template_wb.sheet_names()
datafile_sheet_names = datafile_wb.sheet_names()

if template_sheet_names == datafile_sheet_names: 
    print ("The lists are identical") 
else : 
    print ("The lists are not identical") 

# If list of Sheets are ok, Continue per Sheet validation

def validate_rows_in_sheet(sheet_name,rows):    
    print('Validating Sheet {}'.format(sheet_name))
    template_sheet = template_wb.sheet_by_name(sheet_name)
    datafile_sheet = template_wb.sheet_by_name(sheet_name)
    rows_to_validate = rows
    for row in rows_to_validate:
        print('Validating row {}'.format(row))
        template_headers = template_sheet.row(row)
        datafile_headers= datafile_sheet.row(row)
        if len(template_headers) == len(datafile_headers):
            print ("Header count OK")
        else:
            raise ValueError("Header count NOK")
        template_values = []
        for cell in template_headers:
            template_values.append(cell.value)
        datafile_values = []
        for cell in datafile_headers:
            datafile_values.append(cell.value)        
        if template_values.sort() == datafile_values.sort(): 
            print ("Header Values are identical") 
        else: 
            raise ValueError("Header Values are not identical")
    return 0

for sheet_name in template_sheet_names:
    if sheet_name in 'Option**':
        print(sheet_name)
validate_rows_in_sheet
