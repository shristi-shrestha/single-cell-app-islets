


#Libraries----
library(shiny)
require(shinyjs)
library(Seurat)
library(ggplot2)
library(Matrix)
library(dplyr)
library(shinythemes)
library(shinydashboard)
library(shinyBS)
library(dittoSeq)
library(shinyWidgets)

#Might need this to deploy----
library(BiocManager)
options(repos = BiocManager::repositories())

#load data----
load("DATA/Islets2.Rda")

# Extract Gene description
Gene_desp<-read.csv("DATA/gene_annotation_sorted.csv") # working

#load experimental summary for table3:
t3<-read.csv("DATA/sc meta.csv")

#Single-cell gene expression atlas of human pancreatic islets

#1.Header----
header <- dashboardHeader(titleWidth = "100%",
                          # Set height of dashboardHeader
                          tags$li(class = "dropdown",
                                  tags$style(".main-header {max-height: 200px}"),
                                  tags$style(".main-header .logo {height: 100px}")
                          )
)


#webpage links to the images
anchor <- tags$header(
              tags$a(href='https://www.powersbrissovaresearch.org/',
                             tags$img(src='logo-4.png', width='200',style="float:left; margin:0 70px 10px 20px;" )),
              tags$a(href='https://cds.vanderbilt.edu',
                     tags$img(src='CDS-logo-600x85.png', width='200',style="float:right; margin-left:70px; margin-top:15px; height:auto;" )),
                      #style = "padding-top:100px; padding-bottom:100px;"),
                      'Single cell gene expression atlas of human pancreatic islets',
                      style = "color: #2b6cb3;
                           float:left;
                           /*font-family: Avenir Light;*/
                           font-size: 25px;
                           padding:20px;
                           font-weight: bold"
)


header$children[[2]]$children <- tags$div(
  tags$head(tags$style(HTML(".name { background-color: white } Gene-label { font-size:80%;} "))),
  anchor,
  class = 'name')


#2.User Interface----

#*  Dashboard header----
ui<-dashboardPage(header,
                  title = "Single cell gene expression atlas of human pancreatic islets - Powers & Brissova Research Group",
                 skin = "black",
                 #* Dashboard sidebar ----
                 dashboardSidebar(width = 300,
                                 
                                  sidebarMenu(
                                    id = "tabs",
                                    menuItem("Home", tabName = "home", selected = T),
                                    menuItem(
                                             startExpanded = TRUE,
                                      selectizeInput(inputId = "Gene",
                                                     label = "Enter Official Gene Symbol",
                                                     choices=NULL
                                                     )         
                                      ),
                                    
                                    menuItem("Violinplot", tabName = "vlnplot", icon = icon("vp")),
                                    menuItem("Umap", tabName = "umap", icon = icon("ump")),
                                    menuItem("Dotplot", tabName = "dotplot", icon = icon("dp")),
                                    menuItem("Expression values", tabName = "cellno", icon = icon("cellno")),
                                    menuItem("Manuscript", icon = icon("Manuscript"), href ="https://www.biorxiv.org/content/10.1101/2021.02.23.432522v1"),
                                    menuItem("Experimental Summary", tabName = "expsum", icon = icon("ES"))
                  )
                ),
                
#*  Dashboardbody----         
      dashboardBody(
        useShinyjs(),
        
        tags$head(
          tags$title("Single cell gene expression atlas of human pancreatic islets"),
          tags$style(HTML('
                                            /* body */
                                            .content-wrapper, .right-side {
                                            background-color: #FFFFFF;
                                            }
                                            
                                            /* main sidebar */
                                            .skin-blue .main-sidebar { font-size: 20px;
                                                            background-color: #F0F8FF;
                                            }
                                            .main-sidebar { font-size: 20px; }
                                            
                                            
                                            .left-side, .main-sidebar {
                                            	padding-top: 110px;
                                            }
                                            
                                            /* Gene-label { font-size:70%;} */
                                            
                                            /* image {max-width: 60%; width: 60%; height: auto; } */
                                            
                                            /* fix for spinner showing up in right of plots in large monitors
                                            not elegant, but quick fix */
                                            .loading-spinner { left:25% !important;}
                                            
                                            header { padding-top:20px 0 0 0 !important;}
                                            
                                            '))),
                                
                                
                                #mainPanel(tableOutput("table1")), # gene description table
                                
                                #For violinplot tab
                                tabItems(
          	                      tabItem(tabName = "home",
          	                              fluidPage(
          	                                verticalLayout(tags$h2("Welcome!"),
          	                                               hr(),
          	                                               tags$h4("This app provides interactive access to our single cell RNA-Seq data that is reported in:"),
          	                                               tags$div(
          	                                                 HTML("<p style = 'font-size:20px;'><u><b>Combinatorial transcription factor profiles predict mature and functional human islet α and β cells.</u></b><br></p> Shristi Shrestha*, Diane C. Saunders*, John T. Walker*, Joan Camunas-Soler, Xiao-Qing Dai, Rachana Haliyur, Radhika Aramandla, Greg Poffenberger, Nripesh Prasad, Rita Bottino, Roland Stein, Jean-Philippe Cartailler, Stephen C. J. Parker, Patrick E. MacDonald, Shawn E. Levy, Alvin C. Powers, Marcela Brissova, <b>JCI Insight. 2021 Sep 22 doi: 10.1172/jci.insight.151621 </b><br> *first co-authors <blockquote style='font-size:15px'> Abstract <br> Islet-enriched transcription factors (TFs) exert broad control over cellular processes in pancreatic α and β cells and changes in their expression are associated with developmental state and diabetes. However, the implications of heterogeneity in TF expression across islet cell populations are not well understood. To define this TF heterogeneity and its consequences for cellular function, we profiled >40,000 cells from normal human islets by scRNA-seq and stratified α and β cells based on combinatorial TF expression. Subpopulations of islet cells co-expressing ARX/MAFB (α cells) and MAFA/MAFB (β cells) exhibited greater expression of key genes related to glucose sensing and hormone secretion relative to subpopulations expressing only one or neither TF. Moreover, all subpopulations were identified in native pancreatic tissue from multiple donors. By Patch-seq, MAFA/MAFB co-expressing β cells showed enhanced electrophysiological activity. Thus, these results indicate combinatorial TF expression in islet α and β cells predicts highly functional, mature subpopulations.</blockquote>
          	                                                      "))
          	                                )
          	                              )
          
          	                      ),
                                  tabItem(tabName = "vlnplot", 
                                          fluidPage(
                                            verticalLayout(tableOutput("table1_vlnplot"),
                                                           br(),
                                                           addSpinner(plotOutput("plot1"), spin = "dots", color = "#2b6cb3"),
                                                           plotOutput("plot2"),
                                                           br(),br(),
                                                           sidebarPanel(
                                                             sliderInput("Cellsize", 
                                                                         "Increase Cell Size:",
                                                                         min=-1,
                                                                         max=1,
                                                                         value=0.1,
                                                                         step = 0.1,
                                                                         animate=TRUE),
                                                             hr(),
                                                             helpText("set to -1 to remove dots(cells)")
                                                             
                                                             
                                                             
                                                             
                                                           )
                                            )
                                          )
                                  ),
                                  
                                  #For UMAP plot tab
                                  tabItem(tabName = "umap",
                                          fluidPage(
                                            verticalLayout(tableOutput("table1_umap"),
                                                           br(),
                                                           addSpinner(plotOutput("plot3"), spin = "dots", color = "#2b6cb3"),
                                                           addSpinner(plotOutput("plot4"), spin = "dots", color = "#2b6cb3")
                                            )
                                          )
                                  ),
                                  
                                  #For dotplot tab
                                  tabItem(tabName = "dotplot",
                                          fluidPage(
                                            verticalLayout(tableOutput("table1_dotplot"),
                                                           br(),
                                                           addSpinner(plotOutput("plot5"), spin = "dots", color = "#2b6cb3")
                                            )
                                          )
                                  ),
                                  
                                  #For table on expression counts
                                  tabItem(tabName = "cellno",
                                          fluidPage(
                                            verticalLayout(tableOutput("table1_cellno"),
                                                           br(),
                                                           tableOutput("table2")
                                            )
                                          )
                                  ),
                                  
                                  #Add Manuscript link
                                  tabItem(tabName = "manuscript",
                                          h2(plotOutput("manuscript"))
                                  ),
                                  
                                  tabItem(tabName = "expsum",
                                          fluidPage(
                                            verticalLayout(br(),
                                                           tags$h3(HTML(paste0("<b>","Single Cell RNA-seq Metadata","</b>")) ),
                                                           tableOutput("table3"),
                                                           tags$h6("Metadata format standardized according to",tags$a(href='https://www.nature.com/articles/s41587-020-00744-z',"Fullgrabe et al.,2020"))
                                                                  
                                            )
                                          )
                                  )
                                  
                                  
                                  
                                )))


#3.Server----
server<-function(input, output,session) 
  
  #* table 1 -Gene Description----
{
  observe({
    
    updateSelectizeInput(
      session, 
      'Gene',
      choices = Gene_desp$hgnc_symbol, 
      server = TRUE,
      selected=1
      )
  
  
    # if user interacts with gene filter and is not on umap/vlnplot/dotplot page, then take
    # them to vlnplot, otherwise do not change tab
    observeEvent(input$Gene, {
        
        if (input$tabs == "home" || input$tabs == "cellno" || input$tabs == "expsum" || input$tabs == "cellno") { 
          # it requires an ID of sidebarMenu (in this case)
          updateTabsetPanel(session, inputId="tabs", selected="vlnplot")
        }
      
    }, ignoreInit = TRUE) # ignore initial load, since nothing is actually clicked
  
  })
  
  table1 <- renderTable({
    req(input$Gene)
    #Gene_desp[toupper(input$Gene),]
    Gene_desp %>% filter(hgnc_symbol == input$Gene)
  })
  
  output$table1_vlnplot <- table1
  output$table1_umap <- table1
  output$table1_dotplot <- table1
  output$table1_cellno <- table1
  
  
  #* plot 1 (Violinplot by Cell types)----
  output$plot1<- renderPlot({

    req(input$Gene)
    dittoPlot(Islets, toupper(input$Gene), group.by = "CellTypes",
              plots = c("jitter", "vlnplot", "boxplot"), # <- order matters
              color.panel=c('Alpha'='#F8766D','Beta'='#39B600','Delta'='#D89000','Gamma'='#A3A500','Epsilon'='#00BF7D','Acinar'='#00BFC4','Ductal'='#00B0F6','Endothelial'='#9590FF','Stellate'='#E76BF3','Immune'='#FF62BC'),
              # change the color and size of jitter points
              jitter.color = "black", jitter.size = input$Cellsize,
              legend.title = "Cell types",
              xlab = NULL,
              # change the outline color and width, and remove the fill of boxplots
              boxplot.color = "#636363", boxplot.width = 0.1,
              boxplot.fill = FALSE,
              
              # change how the violin plot widths are normalized across groups
              vlnplot.scaling = "width"
    )+ylab("ln(UMI -per-10,000 +1)")+
      theme(text = element_text(size = 18,
                                face="bold"),
            axis.text = element_text(size = 18,
                                     face="bold"),
            axis.line.x = element_line(color="black",
                                       size = 0.8),
            axis.line.y = element_line(color="black",
                                       size = 0.8))
  }, height = 400, width = 750)
  
  
  #* plot2 (Violin plot by Age)----
  output$plot2<- renderPlot({
    req(input$Gene)
    dittoPlot(Islets, toupper(input$Gene), group.by = "Age",
              plots = c("jitter", "vlnplot", "boxplot"), # <- order matters
              
              # change the color and size of jitter points
              jitter.color = "black", jitter.size = input$Cellsize,
              legend.title = "Donor age",
              xlab = NULL,
              # change the outline color and width, and remove the fill of boxplots
              boxplot.color = "#636363", boxplot.width = 0.1,
              boxplot.fill = FALSE,
              vlnplot.scaling = "width" 
    )+ylab("ln(UMI -per-10,000 +1)")+
      theme(text = element_text(size = 18,
                                face="bold"),
            axis.text = element_text(size = 18,
                                     face="bold"),
            axis.line.x = element_line(color="black",
                                       size = 0.8),
            axis.line.y = element_line(color="black",
                                       size = 0.8))
    
  }, height = 400, width = 700)
  
  
  #* plot3 (umap-celltypes)----
  output$plot3<- renderPlot({
    DimPlot(Islets , reduction = "umap", label = TRUE,pt.size = 1,cols = c('Alpha'='#F8766D','Beta'='#39B600','Delta'='#D89000','Gamma'='#A3A500','Epsilon'='#00BF7D','Acinar'='#00BFC4','Ductal'='#00B0F6','Endothelial'='#9590FF','Stellate'='#E76BF3','Immune'='#FF62BC') )+NoLegend()+
      theme(text = element_text(size = 18,face="bold"),
            axis.text = element_text(size = 18,face="bold"),
            axis.line.x = element_line(color="black", size = 0.8),
            axis.line.y = element_line(color="black", size = 0.8))
  }, height = 400, width = 600)
  
  
  #* plot 4 (umap) ----
  output$plot4<- renderPlot({
    req(input$Gene)
    FeaturePlot(Islets, features = toupper(input$Gene), pt.size =1, cols = c("lightgrey","red"))+
      theme(text = element_text(size = 18,face="bold"),
            axis.text = element_text(size = 18,face="bold"),
            axis.line.x = element_line(color="black", size = 0.8),
            axis.line.y = element_line(color="black", size = 0.8))
  }, height = 400, width = 600)
  
  
  
  #* plot5 (Dotplot) ---- 
  Known.markers<-c("GCG","INS","SST","PPY","GHRL", "PRSS1", "KRT19","PECAM1", "PDGFRB", "HLA-DRA")
  output$plot5<- renderPlot({
    req(input$Gene)
    selected_markers<-Known.markers[!(Known.markers %in% input$Gene)]
    DotPlot(Islets, feature=c(selected_markers,toupper(input$Gene)), dot.scale = 8)+ 
      coord_flip()+ 
      scale_color_gradient2(low = "blue", high = "red",mid = "white")+
      labs(y="", x="Genes")+RotatedAxis()+
      #geom_point(shape = 21) +
      scale_y_discrete(position = "right") +
      theme_light() +
      guides(x =  guide_axis(angle = 45))+
      guides(color = guide_colorbar(title = 'Mean expression z-score'),size = guide_legend("% Cells expressed"))+
      theme(text = element_text(size = 15,face="bold"),
            axis.text = element_text(size = 15,face="bold"))
    
  }, height = 600, width = 800)
  
  
  #* Table2 (Expression Values) ----
  output$table2<-renderTable({
    req(input$Gene)
    ttt<-DotPlot(Islets, feature=toupper(input$Gene))
    tble<-ttt$data
    tble<-tble %>%rename(Gene= features.plot, 
                         CellType=id, 
                         'Mean expression z-score'=avg.exp.scaled,
                         '% Cells expressed'= pct.exp,
                         'Average expression'= avg.exp)
    tble<-tble[ , c(3, 4, 2,1,5)]
    tble<-tble %>% filter_all(any_vars(. %in% toupper(input$Gene)))
    tble
  })
  
  
  #* Table3 (Experimental Summary) ----
  output$table3<-renderTable({
    names(t3) <- NULL
    t3
    
    
  })
}



#4. shinyApp----
shinyApp(ui=ui,server=server)
