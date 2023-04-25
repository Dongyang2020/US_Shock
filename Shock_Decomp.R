
# delta P = delta Pa + delta Pr + delta Py
# take Pa as an example element
# delta Pa = sum(L(p_t1,p_t0)ln(pa_t1/pa_t0)) in all counties

# in all counties, for a two consecutive years
year$L = (year[,p_t1]-year[,p_t0])/log(year[,p_t1]/year[,p_t0]) # L(p_t1, p_t0)
year$sec_a = log(year[,pa_t1]/year[,pa_t0]). # ln(pa_t1/pa_t0)

# sum the changes in all counties
delta_P = sum(year[,p_t1])-sum(year[,p_t0])
delta_Pa = sum(year$L * year$sec_a, na.rm=T) 

# calculate the contribution from Pa
Contr_Pa = delta_Pa/delta_P
