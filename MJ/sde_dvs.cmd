#setdep @node|epi@ 

;; include global stuff that does not need changing (usually)
#include "../lib/sde_dvs.cmd"

;;----------------------------------------------------------------------
(display "Creating  structure") (newline)
(sde:clear)
;;----------------------------------------------------------------------
(display "  Reading in epi layer system") (newline)
(load "@[relpath n@node|epi@_epi.scm]@")


;----------------------------------------------------------------------
; general structure parameters
;; wtot - width of the device [um]
(define wtot @wtot@)
#if @wfrontc@ == 0.0
(define wfrontc @wtot@)
#else
(define wfrontc @wfrontc@)
#endif
(define node "@node@")
(define IllFracOffset 0.1)
(define myRefFrontContactOffset 0.1)

#if @cap_t@ != 0.0
 (define Ytopcell Y0_cap)
 (sdegeo:insert-vertex (position (- wtot wfrontc) Ytopcell 0.0))
#else
!(
	puts "(define Ytopcell Y0_sc@numSegments@_fsf)"
)!
 (sdegeo:insert-vertex (position (- wtot wfrontc) Ytopcell 0.0))
#endif




;;--------------------------------------------------------------------
(display "Add Refinements") (newline)
;;Refinement at the illumination boundary



#if @wfrontc@ > 0.0
;; for 1D simulations:  wfrontc = wtot = 1.0 (1.0 to make it fast)


(display "  etching cap") (newline)
#if @ARC2_t@ != 0.0
(sdegeo:set-default-boolean "ABA")
(define delme (sdegeo:create-rectangle 
	(position wtot Y0_ARC2 0 ) 
	(position (- wtot wfrontc) Y1_ARC2 0 ) "xxx" "xxx"))
(entity:delete delme)
#endif
#if @ARC1_t@ != 0.0
 (sdegeo:set-default-boolean "ABA")
(define delme (sdegeo:create-rectangle 
	(position wtot Y0_ARC1 0 ) 
	(position (- wtot wfrontc) Y1_ARC1 0 ) "xx" "xx"))
(entity:delete delme)
#endif



;;----------------------------
;; add air side layer at far end for side wall recombination
;;---------------------------
#if @sideS@ > 0.0
(sdegeo:create-rectangle
	(position 0.0 Y0_sc1_em 0.0)
	(position -1.0 Y1_sc1_em 0.0)
	"Gas" "Side_Air"
)
;; refinement by sidewall
(sdedr:define-refeval-window "sideWall" "Rectangle"  
  (position  0.0 Y0_sc1_em 0)  
  (position  0.01 Y1_sc1_em 0) )
(sdedr:define-refinement-size "sideWall" 0.1 dYmax 0 0.001 dYmin 0 )
(sdedr:define-refinement-placement "sideWall" "sideWall" "sideWall" )
#endif




;; refinement at illumination on right of contact edge
(sdedr:define-refeval-window "IllFrac_refEval" "Rectangle"  
(position  (- wtot (+ wfrontc IllFracOffset)) Ytopcell 0)  
(position  (- wtot wfrontc) Ybot 0) )   
(sdedr:define-multibox-size "IllFrac" dXmax dYmax dXmin 10 -10.0 0  )
(sdedr:define-multibox-placement "IllFrac" "IllFrac" "IllFrac_refEval" )

;; refinement at illumination on left of contact edge
(sdedr:define-refeval-window "IllFrac_refEval_left" "Rectangle"  
(position  (- wtot wfrontc)  Ytopcell 0)  
(position  (- wtot (- wfrontc IllFracOffset)) Ybot 0) )   
(sdedr:define-multibox-size "IllFrac_left" dXmax dYmax dXmin 10 10.0 0  )
(sdedr:define-multibox-placement "IllFrac_left" "IllFrac_left" "IllFrac_refEval_left" )


;; Refinements at top contact edge
(begin  
	(display "  front contact refinement") (newline)
	(sdedr:define-refeval-window "frontContact" "Rectangle"  
	  (position  (- wtot (- wfrontc myRefFrontContactOffset)) Ytopcell 0)  
	  (position  (- wtot (+ wfrontc myRefFrontContactOffset)) Ybot 0) )
	(sdedr:define-refinement-size "frontContact" 0.1 dYmax 0 0.05 dYmin 0 )
	(sdedr:define-refinement-placement "frontContact" "frontContact" "frontContact" )
)



#endif






#if @InAlAs_SymPos@ > 0.0

;;; ----------------------------------
;; gaussian doping profile 
;;; ----------------------
(define erfY (+ Y0_sc1_base @InAlAs_SymPos@))
(sdedr:define-refeval-window "erfProfStart" "Line"
(position 0.0 erfY 0) (position 1.0 erfY 0))
(sdedr:define-gaussian-profile "erf_BSF"  "BoronActiveConcentration"
"PeakVal" @<-2.0*seg1_ba_dop>@
"StdDev" @InAlAs_StdDev@
"Erf" "Factor" 1.0)
(sdedr:define-analytical-profile-placement "ImplGauss_BSF" "erf_BSF"
"erfProfStart" "Negative" "LocalReplace" "Eval")

#endif 



;;----------------------------------------------------------------------
(display "  cathode") (newline)
(sdegeo:define-contact-set "cathode" 4  (color:rgb 0 1 0 ) "##" )
(sdegeo:set-current-contact-set "cathode")
#if @3D@ == 0.0
	#if @wfrontc@ == 0.0
		(sdegeo:set-contact (find-edge-id (position (/ wtot 2.0) Ytopcell 0)) "cathode")
	#else
		(sdegeo:set-contact (find-edge-id (position (- wtot (/ wfrontc 2.0)) Ytopcell 0)) "cathode")
	#endif
#else
	#if @wfrontc@ == 0.0
		(sdegeo:set-contact (find-face-id (position (/ wtot 2.0) Ytopcell (/ @3D@ 2.0))) "cathode")
	#else
		(sdegeo:set-contact (find-face-id (position (- wtot (/ wfrontc 2.0)) Ytopcell (/ @3D@ 2.0))) "cathode")
	#endif
#endif

;;----------------------------------------------------------------------
(display "  anode") (newline)
(sdegeo:define-contact-set "anode" 4  (color:rgb 1 0 0 ) "##" )
(sdegeo:set-current-contact-set "anode")
#if @3D@ == 0.0
	(sdegeo:set-contact (find-edge-id (position (/ wtot 2.0) Ybot 0)) "anode")
#else
	(sdegeo:set-contact (find-face-id (position (/ wtot 2.0) Ybot (/ @3D@ 2.0))) "anode")
#endif
;;----------------------------------------------------------------------
#if "@eSim_type@" == "Jsc"
(display "  contacts at each segment") (newline)
!(
	for {set i 1} {$i < @numSegments@} {incr i} {
		create_VContact "td${i}_VContact1" "Y0_td${i}_pplus"
		create_VContact "td${i}_VContact2" "Y1_td${i}_nplus"
	}
)!
#endif

;;---------------------------------------------------------------------


;; include the vertex coordinates in the tdr file. Used for mapping between optical and electrical meshes
;;if layer naming/#layers is changed, will need to make changes to file .cmd that is being included
;;;;;;###include "../lib/vertexCoordinates.cmd"
;; include the Optical generation dataset in the tdr file, to later change with correct opt gen data from external source.
#include "../lib/OptGenZero.cmd"

;;----------------------------------------------------------------------
(display "Saving BND and meshing electrical structure") (newline)
(sde:build-mesh "snmesh" "" (string-append "n" node "_msh") )



(display "... done.") (newline)




