library(gplots)
library(gplots)
library(fastcluster)
library(RColorBrewer)
library(colorRamps)
library(pheatmap)
library(ape)
palette <- colorRampPalette(c('blue','white','red'))(50)
for (i in c(17263932,17263933,17263934,17263936,17263937,17263938,17263939,17263941,17263943,17263946,17263947,17263948,17263949,17263950,17263951,17263952,17263953,17263955,17263956,17263957,17263959,17263961,17263962,17263963,17263964,17263965,17263967,17263970,17263971,17263973,17263976,17263977,17263978,17263980,17263981,17263982,17263985,17263986,17263987,17263988,17263989,17263992,17263993,17263994,17263995,17263996)){
    filename=sprintf("plot/NW_0%s.1.gene_cov_norm.tab",i);
    chr <- read.table(filename,header=T,sep="\t",row.names=1)
    chr <- as.matrix(chr)
    ch <- 4
    cw <- 4
    
    fs_row = 5
    fs_col = 5

    pdffile=sprintf("plot/NW_0%s.heatmap.pdf",i)
    pdf(pdffile,height=30,width=5)
    res_t <- pheatmap(chr, fontsize_row = fs_row,
                      fontsize_col = fs_col,
                      cluster_cols = TRUE, cluster_rows = FALSE,
                      col = palette, scale="none",
                      cellheight = ch,
                      cellwidth  = cw,
                      legend = T,main=sprintf("NW_0%s - Depth of coverage",i),
                      );

        res_t <- pheatmap(chr, fontsize_row = fs_row,
                      fontsize_col = fs_col,
                      cluster_cols = TRUE, cluster_rows = FALSE,
                      col = palette, scale="column",
                      cellheight = ch,
                      cellwidth  = cw,
                      legend = T,main=sprintf("NW_0%s - Strain coverage normalized",i),
                      );

    #    res_t <- pheatmap(chr, fontsize_row = fs_row,
    #                  fontsize_col = fs_col,
    #                  cluster_cols = TRUE, cluster_rows = FALSE,
    #                  col = palette, scale="row",
    #                  cellheight = ch,
    #                  cellwidth  = cw,
    #                  legend = T,main=sprintf("SC %d - Gene coverage normalized",i),
    #                  );

}
