FasdUAS 1.101.10   ��   ��    l    ����  O        k        	  r     
  
 I   	�� ��
�� .sysontocTEXT       shor  m    ���� 
��    o      ���� 0 newline newLine 	     l   ��������  ��  ��        l   ��  ��    : 4 set theDatabase to the name of the current database     �   h   s e t   t h e D a t a b a s e   t o   t h e   n a m e   o f   t h e   c u r r e n t   d a t a b a s e      l   ��  ��    T N	set theDatabase to do shell script "echo " & theDatabase & "| sed 's/ /_/g' "     �   � 	 s e t   t h e D a t a b a s e   t o   d o   s h e l l   s c r i p t   " e c h o   "   &   t h e D a t a b a s e   &   " |   s e d   ' s /   / _ / g '   "      l   ��  ��    R L	set outputPath to "/Users/mcala/Documents/annotations/" & theDatabase & "/"     �   � 	 s e t   o u t p u t P a t h   t o   " / U s e r s / m c a l a / D o c u m e n t s / a n n o t a t i o n s / "   &   t h e D a t a b a s e   &   " / "      l   ��   !��     @ :	do shell script "mkdir -p " & (quoted form of outputPath)    ! � " " t 	 d o   s h e l l   s c r i p t   " m k d i r   - p   "   &   ( q u o t e d   f o r m   o f   o u t p u t P a t h )   # $ # l   ��������  ��  ��   $  % & % Q    A ' ( ) ' k    & * *  + , + r     - . - l    /���� / 1    ��
�� 
DTsl��  ��   . o      ���� 0 theitems theItems ,  0 1 0 Z   $ 2 3���� 2 =    4 5 4 o    ���� 0 theitems theItems 5 J    ����   3 R     �� 6��
�� .ascrerr ****      � **** 6 m     7 7 � 8 8 " S e l e c t   s o m e t h i n g !��  ��  ��   1  9�� 9 l  % %��������  ��  ��  ��   ( R      �� : ;
�� .ascrerr ****      � **** : o      ���� 0 error_message   ; �� <��
�� 
errn < o      ���� 0 error_number  ��   ) Z  . A = >���� = >  . 1 ? @ ? l  . / A���� A o   . /���� 0 error_number  ��  ��   @ m   / 0������ > I  4 =�� B C
�� .sysodisAaleR        TEXT B m   4 5 D D � E E  D E V O N t h i n k   P r o C �� F G
�� 
mesS F o   6 7���� 0 error_message   G �� H��
�� 
as A H m   8 9��
�� EAlTwarN��  ��  ��   &  I J I l  B B��������  ��  ��   J  K L K I  B I�� M��
�� .sysonotfnull��� ��� TEXT M m   B E N N � O O : S u m m a r i e s  !�   M a r k d o w n   f i l e s . . .��   L  P Q P l  J J��������  ��  ��   Q  R�� R X   J S�� T S k   ^  U U  V W V r   ^ g X Y X l  ^ c Z���� Z n   ^ c [ \ [ 1   _ c��
�� 
ppth \ o   ^ _���� 0 	therecord 	theRecord��  ��   Y o      ���� 0 thepath thePath W  ] ^ ] r   h q _ ` _ l  h m a���� a n   h m b c b 1   i m��
�� 
rURL c o   h i���� 0 	therecord 	theRecord��  ��   ` o      ���� 0 thelink theLink ^  d e d r   r � f g f I  r ��� h��
�� .sysoexecTEXT���     TEXT h b   r } i j i b   r y k l k m   r u m m � n n 
 e c h o   l o   u x���� 0 thepath thePath j m   y | o o � p p   |   s e d   ' s /   / _ / g '  ��   g o      ���� 0 thetitle theTitle e  q r q r   � � s t s I  � ��� u��
�� .sysoexecTEXT���     TEXT u b   � � v w v b   � � x y x m   � � z z � { {  b a s e n a m e   y o   � ����� 0 thetitle theTitle w m   � � | | � } }   |   c u t   - f 1   - d ' . '  ��   t o      ���� 0 thetitle theTitle r  ~  ~ o   � ����� 0 thetitle theTitle   � � � l  � ���������  ��  ��   �  � � � r   � � � � � l  � � ����� � n   � � � � � 1   � ���
�� 
DTco � o   � ����� 0 	therecord 	theRecord��  ��   � o      ���� 0 
thecomment 
theComment �  ��� � Z   �  � ����� � ?   � � � � � n   � � � � � 1   � ���
�� 
leng � o   � ����� 0 
thecomment 
theComment � m   � �����   � k   � � � �  � � � r   � � � � � m   � � � � � � �   � o      ���� 0 outtext outText �  � � � r   � � � � � c   � � � � � o   � ����� 0 
thecomment 
theComment � m   � ���
�� 
ctxt � o      ���� 0 outtext outText �  � � � r   � � � � � b   � � � � � b   � � � � � m   � � � � � � �  C o m m e n t _ � o   � ����� 0 thetitle theTitle � m   � � � � � � �  . m d � o      ���� 0 thetitle theTitle �  � � � l  � ���������  ��  ��   �  ��� � r   � � � � � I  � ��� ���
�� .DTpacd08DTrc       reco � K   � � � � �� � �
�� 
pnam � o   � ����� 0 thetitle theTitle � �� � �
�� 
DTty � m   � ���
�� Dtypmkdn � �� � �
�� 
pURL � o   � ����� 0 thelink theLink � �� ���
�� 
DTpl � o   � ����� 0 outtext outText��  ��   � o      ���� 0 thenoterecord theNoteRecord��  ��  ��  ��  �� 0 	therecord 	theRecord T o   M N���� 0 theitems theItems��    m      � ��                                                                                  DNtp  alis    B  Macintosh HD                   BD ����DEVONthink Pro.app                                             ����            ����  
 cu             Applications  "/:Applications:DEVONthink Pro.app/  &  D E V O N t h i n k   P r o . a p p    M a c i n t o s h   H D  Applications/DEVONthink Pro.app   / ��  ��  ��       �� � ���   � ��
�� .aevtoappnull  �   � **** � �� ����� � ���
�� .aevtoappnull  �   � **** � k     � �  ����  ��  ��   � �������� 0 error_message  �� 0 error_number  �� 0 	therecord 	theRecord � / ���������� 7�~ ��} D�|�{�z�y�x N�w�v�u�t�s�r�q�p m o�o�n z |�m�l�k ��j�i � ��h�g�f�e�d�c�b�a�� 

�� .sysontocTEXT       shor�� 0 newline newLine
�� 
DTsl� 0 theitems theItems�~ 0 error_message   � �`�_�^
�` 
errn�_ 0 error_number  �^  �}��
�| 
mesS
�{ 
as A
�z EAlTwarN�y 
�x .sysodisAaleR        TEXT
�w .sysonotfnull��� ��� TEXT
�v 
kocl
�u 
cobj
�t .corecnte****       ****
�s 
ppth�r 0 thepath thePath
�q 
rURL�p 0 thelink theLink
�o .sysoexecTEXT���     TEXT�n 0 thetitle theTitle
�m 
DTco�l 0 
thecomment 
theComment
�k 
leng�j 0 outtext outText
�i 
ctxt
�h 
pnam
�g 
DTty
�f Dtypmkdn
�e 
pURL
�d 
DTpl�c 
�b .DTpacd08DTrc       reco�a 0 thenoterecord theNoteRecord����j E�O *�,E�O�jv  	)j�Y hOPW X  �� ����� Y hOa j O ��[a a l kh �a ,E` O�a ,E` Oa _ %a %j E` Oa _ %a %j E` O_ O�a ,E`  O_  a !,j Ma "E` #O_  a $&E` #Oa %_ %a &%E` Oa '_ a (a )a *_ a +_ #a ,j -E` .Y h[OY�XU ascr  ��ޭ