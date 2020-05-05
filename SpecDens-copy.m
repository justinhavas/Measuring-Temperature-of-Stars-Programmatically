function density = SpecDens(wth,Temp)
h = 6.62607004*(10^-34);
c = 2.99792458*(10^8);
kB = 1.3807*(10^-23);
density = (1./((wth).^5)).*(1./(exp((h*c)./(wth.*Temp.*kB))-1));
end