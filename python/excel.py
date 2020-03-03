# Reading an excel file using Python 
import xlrd 

# If list of Sheets are ok, Continue per Sheet validation

def validate_rows_in_sheet(sheet_name,rows,until_col=0):
    print('Validating Sheet {}'.format(sheet_name))
    template_sheet = template_wb.sheet_by_name(sheet_name)
    datafile_sheet = datafile_wb.sheet_by_name(sheet_name)
    rows_to_validate = rows
    for row in rows_to_validate:        
        template_headers = template_sheet.row(row)
        datafile_headers = datafile_sheet.row(row)
        # Trim list when until_col is used
        if until_col > 0:
            print ('Trimming list until Column: {}'.format(until_col))
            del template_headers[until_col:]
            del datafile_headers[until_col:]
            len(template_headers)
            len(datafile_headers)
        # Match the number of Headers
        if len(template_headers) == len(datafile_headers):
            print ("\tHeader count OK: {} vs {}".format(len(template_headers),len(datafile_headers)))
        else:
            msg = "\tHeader count NOK: {} vs {}".format(len(template_headers),len(datafile_headers))
            raise ValueError(msg)
        # Match the Value of each Header
        template_values = []
        for cell in template_headers:
            template_values.append(cell.value)
        datafile_values = []
        for cell in datafile_headers:
            datafile_values.append(cell.value)        
        if template_values.sort() == datafile_values.sort(): 
            print ("\tHeader Values are identical") 
        else: 
            raise ValueError("Header Values are not identical")
    return 0
# Get Template Values
# Give the location of the file 
template_loc = ("template.xlsx")
datafile_loc = ("datafile.xlsx")
  
# To open Workbook 
template_wb = xlrd.open_workbook(template_loc)
datafile_wb = xlrd.open_workbook(datafile_loc)

# Compare Sheet names
template_sheet_names = template_wb.sheet_names()
datafile_sheet_names = datafile_wb.sheet_names()

if template_sheet_names == datafile_sheet_names: 
    print ("All Sheet Names Match") 
else : 
    raise ValueError("Sheet Names Do not Match")

for sheet_name in template_sheet_names:
    if sheet_name == 'Options':
        print('Option')
        validate_rows_in_sheet(sheet_name,[5],15)
    else:
        validate_rows_in_sheet(sheet_name,[0])
