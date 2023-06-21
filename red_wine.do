// import datanya
import delimited C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\winequality_red.csv, clear
// read setiap kolom
ds
// lakukan deskripsi data
summarize fixedacidity  citricacid    chlorides     totalsulfu~e  ph  alcohol volatileac~y  residualsu~r  freesulfur~e  density sulphates     quality
//melakukan looping untuk dapat satu gambar -> tapi gagal
// Set jumlah subplot dan ukuran tampilan
local num_plots 12
local num_rows 2
local num_cols 6
// Buat subplot secara terpisah
foreach var of varlist fixedacidity citricacid chlorides totalsulfu~e ph alcohol volatileac~y residualsu~r freesulfur~e density sulphates quality {
    histogram `var', name(hist_`var') norm
}
// Gabungkan subplot menggunakan graph grid
graph grid `num_rows' `num_cols', ///
    graph(histogram_*) ///
    title("Histograms of Variables") ///
    name(combined) replace
// Mengatur tampilan grafik yang lebih baik
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir/hasil_histogram.png", replace

// export graph
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_density.png", as(png) replace
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_freesulfurdioxide.png", as(png) replace
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_residualsugar.png", as(png) replace
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_volatileacidity.png", as(png) replace
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_alcohol.png", as(png) replace
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_ph.png", as(png) replace
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_totalsulfurdioxide.png", as(png) replace
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_chlorides.png", as(png) replace
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_citricacid.png", as(png) replace
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\hist_fixedacidity.png", as(png) replace

// focus on quality 
// Menghitung value counts
tabulate variabel, generate(count)
// Membuat bar plot
graph bar (count), over(quality) ///
    title("Bar Plot of Value Counts") ///
    ytitle("Count") ///
    name(barplot) ///
    ylabel(, format(%9.0fc))
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\barplot_quality.png", as(png) replace

// heatmap
quietly correlate fixedacidity  citricacid    chlorides     totalsulfu~e  ph  alcohol volatileac~y  residualsu~r  freesulfur~e  density sulphates     quality
// Store the correlation matrix in a matrix variable
matrix C = r(C)
matrix list r(C)
// Create a correlation heatmap using the heatmap package
heatplot C
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\heatplot_stata.png", as(png) replace

// dataprep
// cek missing value 
ssc install mdesc
mdesc
// potong outlier
local i = 1
foreach var of varlist fixedacidity  citricacid    chlorides     totalsulfu~e  ph  alcohol volatileac~y  residualsu~r  freesulfur~e  density sulphates     quality {
	graph box `var', name(`"b`i'"')
	local i = `i' + 1
}
// Combine the boxplot graphs into one image
graph combine b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12, title("Sebelum Menghapus Outlier")
graph save Graph "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\box_before.png"
// simpan dulu 
save "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\sebelum_drop_outlier.dta"
// truncate outlier
foreach var of varlist fixedacidity citricacid chlorides totalsulfu~e ph alcohol volatileac~y residualsu~r freesulfur~e density sulphates quality {
    // Calculate quartiles and IQR
    summarize `var', detail
    local q1 = r(p25)
    local q3 = r(p75)
    local iqr = 1.5 * (`q3' - `q1')
    
    // Calculate upper and lower bounds
    local upper = `q3' + `iqr'
    local lower = `q1' - `iqr'
    
    // Drop outliers for the current variable
    drop if `var' > `upper' | `var' < `lower'
}

// Create boxplots after outlier removal
local l = 1
foreach var of varlist fixedacidity  citricacid    chlorides     totalsulfu~e  ph  alcohol volatileac~y  residualsu~r  freesulfur~e  density sulphates     quality {
	graph box `var', name(`"g`l'"')
	local l = `l' + 1
}
// Combine the boxplot graphs into one image
graph combine g1 g2 g3 g4 g5 g6 g7 g8 g9 g10 g11 g12, title("Setelah Menghapus Outlier")
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\box_after.png", as(png) replace
// deskripsi data setelah potong outlier
save "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\setelah_drop_outlier.dta"
summarize fixedacidity  citricacid    chlorides     totalsulfu~e  ph  alcohol volatileac~y   density sulphates
local h = 1
foreach var in fixedacidity  citricacid    chlorides     totalsulfu~e  ph  alcohol volatileac~y  residualsu~r  freesulfur~e  density sulphates {
	foreach bal in `var'`_std' {
		histogram `bal', name(`"x`h'"')
		local h = `h' + 1
	}
}
graph combine x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11, title(" Sebelum Standarisari pada Variabel")

// standarisasi manual
// Menghitung rata-rata dan standar deviasi variabel
foreach var in fixedacidity volatileacidity citricacid chlorides totalsulfurdioxide density sulphates alcohol {
    summarize `var', meanonly
    local mean = r(mean)
    summarize `var', detail
    local sd = r(sd)

    // Melakukan standarisasi manual
    gen `var'_std = (`var' - `mean') / `sd'
}
// Menghapus variabel asli yang tidak standar
foreach var in fixedacidity volatileacidity citricacid chlorides totalsulfurdioxide density sulphates alcohol {
    drop `var'
}
save "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\terstandarisasi.dta"
local c = 1
foreach var in fixedacidity volatileacidity citricacid chlorides totalsulfurdioxide density sulphates alcohol {
	foreach bal in `var'`_std' {
		histogram `bal', name(`"n`c'"')
		local c = `c' + 1
	}
}
graph combine n1 n2 n3 n4 n5 n6 n7 n8, title("Standarisari pada Variabel")
graph export "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\variable_standard.png", as(png) replace // save as png

// split quality -> good and bad 
gen quality_good = 0
// Label the variable values
replace quality_good =1 if quality >= 7
drop quality
save "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\preprocess_finished.dta"

ds  // lihat nama2 variable 
summarize quality_good residualsu~r  ph fixedacidi~d  citricacid~d  totalsulfu~d  sulphates_~d freesulfur~e volatileac~d  chlorides_~d  density_std alcohol_std
// Modelling 
use "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\preprocess_finished.dta", clear
logit quality_good residualsu~r ph fixedacidi~d citricacid~d totalsulfu~d sulphates_~d freesulfur~e volatileac~d chlorides_~d density_std alcohol_std
logit quality_good totalsulfu~d sulphates_~d volatileac~d alcohol_std
// lr test logit
estimates store unrestricted
logit quality_good
lrtest unrestricted
// aic logit 
estat ic
// Mengestimasi model logit
logit quality_good totalsulfu~d sulphates_~d volatileac~d alcohol_std
// Uji Wald
test totalsulfurdioxide_std = 0
test sulphates_std  = 0
test volatileacidity_std  = 0
test alcohol_std = 0
// APER
estat classification



// probit 
probit quality_good residualsu~r ph fixedacidi~d citricacid~d totalsulfu~d sulphates_~d freesulfur~e volatileac~d chlorides_~d density_std alcohol_std
probit quality_good totalsulfu~d sulphates_~d volatileac~d alcohol_std
// lr test probit
estimates store unrestricted
probit quality_good
lrtest unrestricted
// aic probit
estat ic
// Uji Wald
probit quality_good totalsulfu~d sulphates_~d volatileac~d alcohol_std
test totalsulfurdioxide_std = 0
test sulphates_std  = 0
test volatileacidity_std  = 0
test alcohol_std = 0
// APER
estat classification


use "C:\Users\user\Documents\kuliah\semester-4\cspd\tugas_akhir\preprocess_finished.dta", clear
// Model Logit
logit quality_good totalsulfu~d sulphates_~d volatileac~d alcohol_std
ssc install fitstat
fitstat
predict prob_logit, p
// Generate observation numbers
gen obs_num = _n
// Plot Probabilitas Model Logit
scatter prob_logit obs_num, xtitle("Observation") ytitle("Probability") ///
    msize(small) mcolor(red) yline(0.5, lpattern(dash)) title("Logit Model") legend(off)

// Model Probit
probit quality_good totalsulfu~d sulphates_~d volatileac~d alcohol_std
predict prob_probit, p
fitstat
// Plot Probabilitas Model Probit
scatter prob_probit obs_num, xtitle("Observation") ytitle("Probability") ///
    msize(small) mcolor(blue) yline(0.5, lpattern(dash)) title("Probit Model") legend(off)
drop obs_num




