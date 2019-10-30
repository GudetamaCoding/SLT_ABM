## draw plots of functions
install.packages("tidyverse")
library("tidyverse")
library("ggplot2")

# provide dummy dataset
p <- ggplot(data = data.frame (x = 0), mapping = aes(x = x))

# put in your function after function(x)
fun.1 <- function(x) 0.2 + 0.002 * (x + 0.7 * x ^ 2 - x ^ 3 / 63 )
fun.2 <- function(x) 0.2 + 0.0016 * (x + 0.7 * x ^ 2 - x ^ 3 / 72 )
fun.3 <- function(x) 0.2 + 0.003 * (x + 0.26 * x ^ 2 - x ^ 3 / 200 )
fun.4 <- function(x) 0.4 + 0.003 * (x + 0.7 * x ^ 2 - x ^ 3 / 60 )
fun.5 <- function(x) 0.4 + 0.004 * (x + 0.7 * x ^ 2 - x ^ 3 / 60 )

#Plot multiple functions
v <- p + 
  geom_path( size = 0.8, aes(colour = "#E69F00"),stat="function", fun = fun.1, show.legend = TRUE)+
  geom_path( size = 0.8, aes(colour = "#009E73"), stat="function", fun = fun.2) +
  geom_path( size = 0.8, aes(colour = "#56B4E9"), stat="function", fun = fun.3) +
  geom_path( size = 0.8, aes(colour = "#0072B2"), stat="function", fun = fun.4) +
  geom_path (size = 0.8, aes(colour = "#999999"), stat="function", fun = fun.5) +
  scale_x_continuous(limits = c(0, 50) ) +
scale_colour_identity("Agents", guide="legend" , labels = c("submerged macrophyte","greenalgae","cyanobacteria","floating plant","diatom"))
print ( v + ggtitle("Gross production rate and temperature") + theme (plot.title = element_text(hjust = 0.5)) + xlab("temperature") + ylab("gross production rate")) 

