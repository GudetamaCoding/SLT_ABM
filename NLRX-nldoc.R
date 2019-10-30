###THIS IS A SCRIPT TO USE nlxr PACKAGE FOR NETLOGO MODEL STATISTICS AND DOCUMENTATION
#reference: Author(s) Jan Salecker jsaleck@gwdg.de 
## IN PACKAGE nlrx, nldoc FUNCTION TO WRITE UP DOCUMENT AUTOMATICALLY
library("nlrx")

# List model files (.nls subfiles are also supported)

modelfiles <- c("https://raw.githubusercontent.com/nldoc/nldoc_pg/master/WSP.nlogo",
                "https://raw.githubusercontent.com/nldoc/nldoc_pg/master/WSP.nls")

# Define output directory:
outdir <- tempdir() # adjust path to your needs

# Create documentation:
nldoc(modelfiles = modelfiles,
      infotab=TRUE,
      gui=TRUE,
      bs=TRUE,
      outpath = outdir,
      output_format = "html",
      number_sections = TRUE,
      theme = "cosmo",
      date = date(),
      toc = TRUE)
#Check where the document is 
tempdir()