library(NeuroDecodeR)

binned_data <- file.path('../../data/binned/ZD_150bins_50sampled.Rda') 


ds <- ds_basic(
	binned_data = binned_data,
	labels = 'combined_ID_position',
	num_label_repeats_per_cv_split = 1,
	num_cv_splits = 2,
	num_resample_sites = 132) 


cl <- cl_max_correlation(return_decision_values = TRUE) 


fp_zs <- fp_zscore()

fps <- list(fp_zs) 


rm_main <- rm_main_results(
	 include_norm_rank_results = TRUE)
rm_cm <- rm_confusion_matrix(
	 save_TCD_results = TRUE,
	 create_decision_vals_confusion_matrix = TRUE)
rms <- list(rm_main, rm_cm)


cv <- cv_standard(
	 datasource = ds,
	 classifier = cl, 
	 feature_preprocessors = fps,
	 result_metrics = rms) 


DECODING_RESULTS <- run_decoding(cv)

paste('The analysis ID is:',
        DECODING_RESULTS$cross_validation_paramaters$analysis_ID)


log_save_results(DECODING_RESULTS, 
	file.path('/home/wz354/project/NeuralDecoding/NeuralDecoding/results', 'decoding_results', 'decoding_result_files', ''))


