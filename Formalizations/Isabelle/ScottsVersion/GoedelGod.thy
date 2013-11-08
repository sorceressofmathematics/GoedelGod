(*<*) 
theory GoedelGod
imports Main 

begin
(*>*)

section {* Introduction *}
 text {* Dana Scott's version \cite{ScottNotes}
 of Goedel's ontological argument \cite{GoedelNotes} for God's existence is here
 formalized in quantified modal logic KB (QML KB) within the proof assistant Isabelle/HOL. 
 QML KB is  modeled as a fragment of classical higher-order logic (HOL); 
 thus, the formalization is essentially a formalization in HOL. The employed embedding 
 of QML KB in HOL is adapting the work of Benzm\"uller and Paulson \cite{J23,B9}.
 Note that the QML KB formalization employs quantification over individuals and 
 quantification over sets of individuals (properties).

 The gaps in Scott's proof have been automated 
 with Sledgehammer \cite{Sledgehammer}, performing remote calls to the higher-order automated
 theorem prover LEO-II \cite{LEO-II}. Sledgehammer then suggests the 
 Metis \cite{Metis} calls. The Metis proofs are verified by Isabelle/HOL.
 For consistency checking, the model finder Nitpick \cite{Nitpick} has been employed.
 
 Isabelle is described in the textbook by Nipkow, 
 Paulson, and Wenzel \cite{Isabelle} and in tutorials available 
 at: \url{http://isabelle.in.tum.de}.
 
\subsection{Related Work}

 The formalization presented here is related to the THF \cite{J22} and 
 Coq \cite{Coq} formalizations at 
 \url{https://github.com/FormalTheology/GoedelGod/tree/master/Formalizations/}.
 
 A medieval ontological argument by Anselm was formalized in PVS by John Rushby \cite{ToDo}.
 \end{enumerate} *}

section {* An Embedding of QML KB in HOL *}

text {* The types @{text "i"} for possible worlds and $\mu$ for individuals 
are introduced. *}

  typedecl i    -- "the type for possible worlds" 
  typedecl \<mu>    -- "the type for indiviuals"      

text {* Possible worlds are connected by an accessibility relation @{text "r"}.*} 

  consts r :: "i \<Rightarrow> i \<Rightarrow> bool" (infixr "r" 70)    -- "accessibility relation r"

text {* The @{text "B"} axiom (symmetry) for relation r is stated. @{text "B"} is needed only 
for proving theorem T3. *}

  axiomatization where sym: "x r y \<longrightarrow> y r x"    

text {* QML formulas are translated as HOL terms of type @{typ "i \<Rightarrow> bool"}. 
This type is abbreviated as @{text "\<sigma>"}. *}

  type_synonym \<sigma> = "(i \<Rightarrow> bool)"
 
text {* The classical connectives $\neg, \wedge, \rightarrow$, and $\forall$
(over individuals and over sets of individuals) and $\exists$ (over individuals) are
lifted to type $\sigma$. The lifted connectives are @{text "m\<not>"}, @{text "m\<and>"}, @{text "m\<Rightarrow>"},
@{text "\<forall>"}, @{text "\<Pi>"}, and @{text "\<exists>"}. Other connectives could be introduced analogously. 
Definitions could be used instead of abbreviations. *}

  abbreviation mnot :: "\<sigma> \<Rightarrow> \<sigma>" ("m\<not>") where "m\<not> \<phi> \<equiv> (\<lambda>w. \<not> \<phi> w)"    
  abbreviation mand :: "\<sigma> \<Rightarrow> \<sigma> \<Rightarrow> \<sigma>" (infixr "m\<and>" 79) where "\<phi> m\<and> \<psi> \<equiv> (\<lambda>w. \<phi> w \<and> \<psi> w)"   
  abbreviation mimplies :: "\<sigma> \<Rightarrow> \<sigma> \<Rightarrow> \<sigma>" (infixr "m\<Rightarrow>" 74) where "\<phi> m\<Rightarrow> \<psi> \<equiv> (\<lambda>w. \<phi> w \<longrightarrow> \<psi> w)"  
  abbreviation mforall :: "('a \<Rightarrow> \<sigma>) \<Rightarrow> \<sigma>" ("\<forall>") where "\<forall> \<Phi> \<equiv> (\<lambda>w. \<forall>x. \<Phi> x w)"   
(*  abbreviation mforall_indset :: "(('a \<Rightarrow> \<sigma>) \<Rightarrow> \<sigma>) \<Rightarrow> \<sigma>" ("\<Pi>") where "\<Pi> \<Phi> \<equiv> (\<lambda>w. \<forall>x. \<Phi> x w)" *)
  abbreviation mexists :: "(\<mu> \<Rightarrow> \<sigma>) \<Rightarrow> \<sigma>" ("\<exists>") where "\<exists> \<Phi> \<equiv> (\<lambda>w. \<exists>x. \<Phi> x w)"
  abbreviation mbox :: "\<sigma> \<Rightarrow> \<sigma>" ("\<box>") where "\<box> \<phi> \<equiv> (\<lambda>w. \<forall>v.  w r v \<longrightarrow> \<phi> v)"
  abbreviation mdia :: "\<sigma> \<Rightarrow> \<sigma>" ("\<diamond>") where "\<diamond> \<phi> \<equiv> (\<lambda>w. \<exists>v. w r v \<and> \<phi> v)" 
  
text {* For grounding lifted formulas, the meta-predicate @{text "valid"} is introduced. *}

  (*<*) no_syntax "_list" :: "args \<Rightarrow> 'a list" ("[(_)]") (*>*) 
  abbreviation valid :: "\<sigma> \<Rightarrow> bool" ("[_]") where "[p] \<equiv> \<forall>w. p w"
  
section {* G\"odel's Ontological Argument *}  
  
text {* Constant symbol @{text "P"} (G\"odel's `Positive') is declared. *}

  consts P :: "(\<mu> \<Rightarrow> \<sigma>) \<Rightarrow> \<sigma>"  

text {* The meaning of @{text "P"} is restricted by axioms @{text "A1(a/b)"}: $\all \varphi 
[P(\neg \varphi) \biimp \neg P(\varphi)]$ (Either a property or its negation is positive, but not both.) 
and @{text "A2"}: $\all \varphi \all \psi [(P(\varphi) \wedge \nec \all x [\varphi(x) \imp \psi(x)]) 
\imp P(\psi)]$ (A property necessarily implied by a positive property is positive). *}

  axiomatization where
    A1a: "[\<forall> (\<lambda>\<phi>. P (\<lambda>x. m\<not> (\<phi> x)) m\<Rightarrow> m\<not> (P \<phi>))]" and
    A1b: "[\<forall> (\<lambda>\<phi>. m\<not> (P \<phi>) m\<Rightarrow> P (\<lambda>x. m\<not> (\<phi> x)))]" and
    A2:  "[\<forall> (\<lambda>\<phi>. \<forall> (\<lambda>\<psi>. (P \<phi> m\<and> \<box> (\<forall> (\<lambda>x. \<phi> x m\<Rightarrow> \<psi> x))) m\<Rightarrow> P \<psi>))]"

text {* We prove theorem T1: $\all \varphi [P(\varphi) \imp \pos \ex x \varphi(x)]$ (Positive 
properties are possibly exemplified). T1 is proved directly by Sledgehammer with command @{text 
"sledgehammer [provers = remote_leo2]"}. 
Sledgehammer suggests to call Metis with axioms A1a and A2. 
Metis sucesfully generates a proof object 
that is verified in Isabelle/HOL's kernel. *}
 
  theorem T1: "[\<forall> (\<lambda>\<phi>. P \<phi> m\<Rightarrow> \<diamond> (\<exists> \<phi>))]"  
  sledgehammer [provers = remote_leo2] 
  by (metis A1a A2)

text {* Next, the symbol @{text "G"} for `God-like'  is introduced and defined 
as $G(x) \biimp \forall \varphi [P(\phi) \to \varphi(x)]$ \\ (A God-like being possesses 
all positive properties). *} 

  definition G :: "\<mu> \<Rightarrow> \<sigma>" where "G = (\<lambda>x. \<forall> (\<lambda>\<phi>. P \<phi> m\<Rightarrow> \<phi> x))"   

text {* Axiom @{text "A3"} is added: $P(G)$ (The property of being God-like is positive).
Sledgehammer and Metis then prove corollary @{text "C"}: $\pos \ex x G(x)$ 
(Possibly, God exists). *} 
 
  axiomatization where A3:  "[P G]" 

  corollary C: "[\<diamond> (\<exists> G)]" 
  sledgehammer [provers = remote_leo2] by (metis A3 T1)

text {* Axiom @{text "A4"} is added: $\all \phi [P(\phi) \to \Box \; P(\phi)]$ 
(Positive properties are necessarily positive). *}

  axiomatization where A4:  "[\<forall> (\<lambda>\<phi>. P \<phi> m\<Rightarrow> \<box> (P \<phi>))]" 

text {* Symbol @{text "ess"} for `Essence' is introduced and defined as 
$\ess{\varphi}{x} \biimp \varphi(x) \wedge \all \psi (\psi(x) \imp \nec \all y (\varphi(y) 
\imp \psi(y)))$ (An \emph{essence} of an individual is a property possessed by it 
and necessarily implying any of its properties). *}

  definition ess :: "(\<mu> \<Rightarrow> \<sigma>) \<Rightarrow> \<mu> \<Rightarrow> \<sigma>" (infixr "ess" 85) where
    "\<phi> ess x = \<phi> x m\<and> \<forall> (\<lambda>\<psi>. \<psi> x m\<Rightarrow> \<box> (\<forall> (\<lambda>y. \<phi> y m\<Rightarrow> \<psi> y)))"

text {* Next, Sledgehammer and Metis prove theorem @{text "T2"}: $\all x [G(x) \imp \ess{G}{x}]$ 
(Being God-like is an essence of any God-like being). *}

  theorem T2: "[\<forall> (\<lambda>x. G x m\<Rightarrow> G ess x)]"
  sledgehammer [provers = remote_leo2] by (metis A1b A4 G_def ess_def)

text {* Symbol @{text "NE"}, for `Necessary Existence', is introduced and
defined as $\NE(x) \biimp \all \varphi [\ess{\varphi}{x} \imp \nec \ex y \varphi(y)]$ (Necessary 
existence of an individual is the necessary exemplification of all its essences). *}

  definition NE :: "\<mu> \<Rightarrow> \<sigma>" where "NE = (\<lambda>x. \<forall> (\<lambda>\<phi>. \<phi> ess x m\<Rightarrow> \<box> (\<exists> \<phi>)))"

text {* Moreover, axiom @{text "A5"} is added: $P(\NE)$ (Necessary existence is a positive 
property). *}

  axiomatization where A5:  "[P NE]"

text {* Finally, Sledgehammer and Metis prove the main theorem @{text "T3"}: $\nec \ex x G(x)$ 
(Necessarily, God exists). *}

  theorem T3: "[\<box> (\<exists> G)]" 
  sledgehammer [provers = remote_leo2] by (metis A5 C T2 sym G_def NE_def)

  corollary C2: "[\<exists> G]" 
  sledgehammer [provers = remote_leo2](T1 T3 G_def sym) by (metis T1 T3 G_def sym)

text {* The consistency of the entire theory is checked with Nitpick. *}

  lemma True nitpick [satisfy, user_axioms, expect = genuine] oops 

(*<*) 
end
(*>*) 