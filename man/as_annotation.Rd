% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_annotation.R
\name{as_annotation}
\alias{as_annotation}
\title{Make object into class freesurfer_annotation}
\usage{
as_annotation(x)
}
\arguments{
\item{x}{list of three: vertices, labels and colortable}
}
\description{
Make object into class freesurfer_annotation
}
\examples{
if (have_fs()) {
 bert_dir = file.path(fs_subj_dir(), "bert")
 annot_file = file.path(bert_dir, "label", "lh.aparc.annot")
 res = read_annotation(annot_file)
    
 as_annotation(list(
   vertices = res$vertices,
   labels = res$labels,
   colortable = res$colortable
 ))
} 
}
