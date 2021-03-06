#' @title Reconstruction from Freesurfer
#' @description Reconstruction from Freesurfer with most of the options
#' implemented.
#' 
#' @param infile Input filename (dcm or nii)
#' @param outdir Output directory
#' @param subjid subject id
#' @param motioncor When there are multiple source volumes, this step will 
#' correct for small motions between them and then average them together. 
#' The input are the volumes found in file(s) mri/orig/XXX.mgz. The output 
#' will be the volume mri/orig.mgz. If no runs are found, then it looks for 
#' a volume in mri/orig (or mri/orig.mgz). If that volume is there, then it 
#' is used in subsequent processes as if it was the motion corrected volume. 
#' If no volume is found, then the process exits with errors.
#' @param nuintensitycor Non-parametric Non-uniform intensity Normalization 
#' (N3), corrects for intensity non-uniformity in MR data, making relatively 
#' few assumptions about the data. This runs the MINC tool 'nu_correct'. By 
#' default, four iterations of nu_correct are run. The flag '-nuiterations'
#' specification of some other number of iterations.
#' @param talairach computes the affine transform from the orig volume to the 
#' MNI305 atlas using the MINC program mritotal. 
#' Creates the files mri/transform/talairach.auto.xfm and talairach.xfm.
#' @param normalization Performs intensity normalization of the orig 
#' volume and places the result in mri/T1.mgz
#' @param skullstrip Removes the skull from mri/T1.mgz and 
#' stores the result in mri/brainmask.auto.mgz and 
#' mri/brainmask.mgz. Runs the mri_watershed program.
#' @param gcareg Computes transform to align the mri/nu.mgz volume 
#' to the default GCA atlas found in FREESURFER_HOME/average. 
#' Creates the file mri/transforms/talairach.lta. 
#' @param canorm Further normalization, based on GCA model. 
#' Creates mri/norm.mgz.
#' @param careg Computes a nonlinear transform to align with GCA atlas. 
#' Creates the file mri/transform/talairach.m3z.
#' @param rmneck The neck region is removed from the NU-corrected volume mri/nu.mgz. 
#' Makes use of transform computed from prior CA Register stage. 
#' Creates the file mri/nu_noneck.mgz.
#' @param skull_lta Computes transform to align volume mri/nu_noneck.mgz
#'  with GCA volume possessing the skull. 
#'  Creates the file mri/transforms/talairach_with_skull.lta.
#' @param calabel Labels subcortical structures, based in GCA model. 
#' Creates the files mri/aseg.auto.mgz and mri/aseg.mgz.
#' @param normalization2 Performs a second (major) intensity correction 
#' using only the brain volume as the input 
#' (so that it has to be done after the skull strip). 
#' Intensity normalization works better when the skull 
#' has been removed. Creates a new brain.mgz volume. 
#' If -noaseg flag is used, then aseg.mgz is not used by mri_normalize.
#' @param segmentation Attempts to separate white matter from 
#' everything else. The input is mri/brain.mgz, and the 
#' output is mri/wm.mgz. Uses intensity, neighborhood, 
#' and smoothness constraints. This is the volume that is 
#' edited when manually fixing defects. Calls mri_segment, 
#' mri_edit_wm_with_aseg, and mri_pretess. To keep previous edits, 
#' run with -keepwmedits. If -noaseg is used, them mri_edit_wm_aseg 
#' is skipped.
#' @param fill This creates the subcortical mass from which the orig 
#' surface is created. The mid brain is cut from the cerebrum, 
#' and the hemispheres are cut from each other. The left hemisphere 
#' is binarized to 255. The right hemisphere is binarized to 127. 
#' The input is mri/wm.mgz and the output is mri/filled.mgz. 
#' Calls mri_fill. If the cut fails, then seed points can be supplied 
#' (see -cc-crs, -pons-crs, -lh-crs, -rh-crs). 
#' The actual points used for the cutting planes in the corpus callosum
#'  and pons can be found in scripts/ponscc.cut.log. 
#'  This is the last stage of volumetric processing. 
#'  If -noaseg is used, then aseg.mgz is not used by mri_fill.
#' @param tessellate This is the step where the orig surface 
#' (ie, surf/?h.orig.nofix) is created. 
#' The surface is created by covering the filled hemisphere 
#' with triangles. Runs mri_tessellate. The places where the 
#' points of the triangles meet are called vertices. 
#' Creates the file surf/?h.orig.nofix Note: the 
#' topology fixer will create the surface ?h.orig.
#' @param smooth1 Calls mris_smooth. Smooth1 is the step just after tessellation
#' @param inflate1 Inflation of the surf/?h.smoothwm(.nofix) surface to create surf/?h.inflated. 
#' @param qsphere automatic topology fixing. It is a quasi-homeomorphic spherical transformation of the inflated surface designed to localize topological defects for the subsequent automatic topology fixer.
#' @param fix Finds topological defects (ie, holes in a filled hemisphere) using surf/?h.qsphere.nofix, and changes the orig surface (surf/?h.orig.nofix) to remove the defects. Changes the number of vertices. All the defects will be removed, but the user should check the orig surface in the volume to make sure that it looks appropriate. Calls mris_fix_topology. 
#' @param finalsurfs Creates the ?h.white and ?h.pial surfaces as well as the thickness file (?h.thickness) and curvature file (?h.curv). The white surface is created by "nudging" the orig surface so that it closely follows the white-gray intensity gradient as found in the T1 volume. The pial surface is created by expanding the white surface so that it closely follows the gray-CSF intensity gradient as found in the T1 volume. Calls mris_make_surfaces.
#' @param smooth2 the step just after topology fixing.
#' @param inflate2 inflate2 is the step just after topology fixing 
#' @param cortribbon Creates binary volume masks of the cortical ribbon, ie, each voxel is either a 1 or 0 depending upon whether it falls in the ribbon or not. Saved as ?h.ribbon.mgz. Uses mgz regardless of whether the -mgz option is used. 
#' @param sphere Inflates the orig surface into a sphere while minimizing metric distortion. This step is necessary in order to register the surface to the spherical atlas. (also known as the spherical morph). Calls mris_sphere. Creates surf/?h.sphere.
#' @param surfreg Registers the orig surface to the spherical atlas through surf/?h.sphere. The surfaces are first coarsely registered by aligning the large scale folding patterns found in ?h.sulc and then fine tuned using the small-scale patterns as in ?h.curv. Calls mris_register. Creates surf/?h.sphere.reg.
#' @param contrasurfreg Same as ipsilateral but registers to the contralateral atlas. Creates lh.rh.sphere.reg and rh.lh.sphere.reg.
#' @param avgcurv Resamples the average curvature from the atlas to that of the subject. Allows the user to display activity on the surface of an individual with the folding pattern (ie, anatomy) of a group. Calls mrisp_paint. Creates surf/?h.avg_curv.
#' @param cortparc Assigns a neuroanatomical label to each location on the cortical surface. Incorporates both geometric information derived from the cortical model (sulcus and curvature), and neuroanatomical convention. Calls mris_ca_label. -cortparc creates label/?h.aparc.annot, and -cortparc2 creates /label/?h.aparc.a2005s.annot.
#' @param parcstats Runs mris_anatomical_stats to create a summary table of cortical parcellation statistics for each structure, including 1. structure name 2. number of vertices 3. total surface area (mm2) 4. total gray matter volume (mm3) 5. average cortical thickness (mm) 6. standard error of cortical thickness (mm) 7. integrated rectified mean curvature 8. integrated rectified Gaussian curvature 9. folding index 10. intrinsic curvature index. For -parcstats, the file is saved in stats/?h.aparc.stats. For -parcstats2, the file is saved in stats/?h.aparc.a2005s.stats.
#' @param cortparc2 see cortparc argument
#' @param parcstats2 see cortparc2 argument 
#' @param aparc2aseg Maps the cortical labels from the automatic cortical parcellation (aparc) to the automatic segmentation volume (aseg). The result can be used as the aseg would.
#' @param verbose print diagnostic messages
#' @param opts Additional options
#'
#' @return Result of \code{\link{system}}
#' @export
recon <- function(
  infile,
  outdir = NULL,
  subjid,
  motioncor = TRUE,
  nuintensitycor = TRUE,
  talairach = TRUE,
  normalization = TRUE,
  skullstrip = TRUE,
  gcareg = TRUE,
  canorm = TRUE,
  careg = TRUE,
  rmneck = TRUE,
  skull_lta = TRUE,
  calabel = TRUE,
  normalization2 = TRUE,
  segmentation = TRUE,
  fill = TRUE,
  tessellate = TRUE,
  smooth1 = TRUE,
  inflate1 = TRUE,
  qsphere = TRUE,
  fix = TRUE,
  finalsurfs = TRUE,
  smooth2 = TRUE,
  inflate2 = TRUE,
  cortribbon = TRUE,
  sphere = TRUE,
  surfreg = TRUE,
  contrasurfreg = TRUE,
  avgcurv = TRUE,
  cortparc = TRUE,
  parcstats = TRUE,
  cortparc2 = TRUE,
  parcstats2 = TRUE,
  aparc2aseg = TRUE,
  verbose = TRUE,
  opts = ""
) {
  
  if (is.null(subjid)) {
    subjid = nii.stub(infile, bn = TRUE)
    subjid = file_path_sans_ext(subjid)
  }  
  infile = checknii(infile)
  log_opts = c(
    "motioncor" = motioncor,
    "nuintensitycor" = nuintensitycor,
    "talairach" = talairach,
    "normalization" = normalization,
    "skullstrip" = skullstrip,
    "gcareg" = gcareg,
    "canorm" = canorm,
    "careg" = careg,
    "rmneck" = rmneck,
    "skull-lta" = skull_lta,
    "calabel" = calabel,
    "normalization2" = normalization2,
    "segmentation" = segmentation,
    "fill" = fill,
    "tessellate" = tessellate,
    "smooth1" = smooth1,
    "inflate1" = inflate1,
    "qsphere" = qsphere,
    "fix" = fix,
    "finalsurfs" = finalsurfs,
    "smooth2" = smooth2,
    "inflate2" = inflate2,
    "cortribbon" = cortribbon,
    "sphere" = sphere,
    "surfreg" = surfreg,
    "contrasurfreg" = contrasurfreg,
    "avgcurv" = avgcurv,
    "cortparc" = cortparc,
    "parcstats" = parcstats,
    "cortparc2" = cortparc2,
    "parcstats2" = parcstats2,
    "aparc2aseg" = aparc2aseg
  )
  
  parse_opts = function(log_opts) {
    n = names(log_opts)
    n[ !log_opts ] = paste0("no", n[ !log_opts ])
    n = paste0("-", n)
    n = paste(n, collapse = " ")
    return(n)
  }
  if (!is.null(outdir)) {
    sd_opts = paste0(" -sd ", shQuote(outdir))
  } else {
    sd_opts = ""
  }
  
  args = parse_opts(log_opts)
  opts = paste(
    paste0("-i", infile),
    sd_opts,
    paste0(" -subjid ", subjid),
    args,
    opts)
  
  cmd = get_fs()
  cmd = paste(cmd, opts)
  if (verbose) {
    message(cmd, "\n")
  }
  res = system(cmd)
  return(res)
}