# Calculate climate extreme indicators -- SPI and SPEI 
# 2022.03.23 Dongyang Wei

# install.packages("SPEI")
library(SPEI)
library(reshape2)
library(stringr)


# 1.preparation ####
# 1.1 build a final dataframe
final_spi = data.frame()
colnames(final_spi)="ct_proj.atlas_stco"
final_spei = final_spi

# 1.2 find corresponding lat
# data from https://en.wikipedia.org/wiki/User:Michael_J/County_table#cite_note-sortcode-1  
df_lat = read.csv("county_geo_loc.csv")


# 2.loop for each county
for (i in 1:3070){

  # 2.1 setup codes
  cd = final_spi[i,"ct_proj.atlas_stco"]
  lat_cd = df_lat[df_lat$FIPS==cd,"lat"]
  
  
  # 2.2 format monthly climate data
  clim_all = data.frame()
  
  for (j in 1:40){
    fname_ppt = paste("PRISM/output/ppt_mon/ppt_",j+1980,".csv",sep="")
    ppt = read.csv(fname_ppt, row.names=1)
    ppt = ppt[ppt$ct_proj.atlas_stco == cd,]
    ppt <- melt(ppt, id=c("ct_proj.atlas_stco","year"))
    ppt$month = str_split_fixed(ppt$variable,"_",2)[,2]
    ppt = ppt[,c("ct_proj.atlas_stco","year","month","value")]
    
    fname_tmax = paste("PRISM/output/tmax_mon/tmax_",j+1980,".csv",sep="")
    tmax = read.csv(fname_tmax, row.names=1)
    tmax = tmax[tmax$ct_proj.atlas_stco == cd,]
    tmax <- melt(tmax, id=c("ct_proj.atlas_stco","year"))
    tmax$month = str_split_fixed(tmax$variable,"_",2)[,2]
    tmax = tmax[,c("ct_proj.atlas_stco","year","month","value")]
    
    fname_tmin = paste("PRISM/output/tmin_mon/tmin_",j+1980,".csv",sep="")
    tmin = read.csv(fname_tmin, row.names=1)
    tmin = tmin[tmin$ct_proj.atlas_stco == cd,]
    tmin <- melt(tmin, id=c("ct_proj.atlas_stco","year"))
    tmin$month = str_split_fixed(tmin$variable,"_",2)[,2]
    tmin = tmin[,c("ct_proj.atlas_stco","year","month","value")]
    
    clim = merge(ppt, tmax, by=c("ct_proj.atlas_stco","year","month"))
    clim = merge(clim, tmin, by=c("ct_proj.atlas_stco","year","month"))  
    colnames(clim) = c("code","year","month","ppt","tmax","tmin")
    
    clim_all = rbind(clim_all,clim)
    clim_all$month = strtoi(clim_all$month) 
    clim_all = clim_all[order(clim_all$year,clim_all$month),]
    rownames(clim_all) = NULL
  }
    
  # 2.3 calculate mean SPEI6 during Growing Season
  clim_all$PET = hargreaves(Tmin = clim_all$tmin, Tmax = clim_all$tmax,lat = lat_cd)
  CWBAL = clim_all$ppt - clim_all$PET
  spei6 = spei(CWBAL,6)
  df_spei6 = data.frame(clim_all[,c("code","year","month")],spei6[3])
  df_spei6 = reshape(df_spei6, direction = 'wide',idvar=c("code","year"),timevar = "month")
  df_spei6$mean_spei6 = rowMeans(df_spei6[,5:12],na.rm=TRUE) # from Mar to Oct # change HERE

  # 2.4 calculate mean SPI6 during Growing Season
  spi6 = spi(clim_all$ppt,6)
  df_spi6 = data.frame(clim_all[,c("code","year","month")],spi6[3])
  df_spi6 = reshape(df_spi6, direction = 'wide',idvar=c("code","year"),timevar = "month")
  df_spi6$mean_spi6 = rowMeans(df_spi6[,5:12],na.rm=TRUE) # from Mar to Oct # change HERE
  
  final_spi[final_spi$'ct_proj.atlas_stco' == cd,2:41] = df_spi6$mean_spi6
  final_spei[final_spei$'ct_proj.atlas_stco' == cd,2:41] = df_spei6$mean_spei6
}


colnames(final_spi) = colnames(final_spei) = c("ct_proj.atlas_stco", 1981:2020)

write.csv(final_spi, "spi6.csv")
write.csv(final_spei, "spei6.csv")
