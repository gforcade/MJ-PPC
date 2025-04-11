source /h/mwilkins/STDB/GaInP_GaAs_GaInAs_IMM/lib/PhysicalConstants.tcl

set TDD_vals [list 1e4 2e4 5e4 1e5 2e5 5e5 1e6 2e6 5e6 1e7 2e7 5e7 1e8 2e8 5e8 1e9]
foreach ::TDD $TDD_vals {

set ::temp 300.0
set ::doping 1e17

source MW-TDD.tcl
puts "$::TDD $::InGaAs::Scharfetter::taumax_n $::InGaAs::Scharfetter::taumax_p "
}
