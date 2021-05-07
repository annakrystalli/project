get_stem_location <- function(decimalLongitude, decimalLatitude,
                              stemAzimuth, stemDistance) {
  
  # validation checks on inputs
  checkmate::assert_numeric(decimalLatitude)
  checkmate::assert_numeric(decimalLongitude)
  checkmate::assert_numeric(stemAzimuth)
  checkmate::assert_numeric(stemDistance)
  
  out <- geosphere::destPoint(p = cbind(decimalLongitude, 
                                        decimalLatitude),
                              b = stemAzimuth, d = stemDistance) %>%
    as.data.frame()
  
  # validation check on output
  checkmate::assert_false(any(is.na(out)))
  
  return(out)
}