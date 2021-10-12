PGDMP     ;                	    y           ByteLeRoyaleDB    13.4    13.4 '    �           0    0    ENCODING    ENCODING     #   SET client_encoding = 'SQL_ASCII';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16394    ByteLeRoyaleDB    DATABASE     t   CREATE DATABASE "ByteLeRoyaleDB" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_United States.1252';
     DROP DATABASE "ByteLeRoyaleDB";
                postgres    false                        3079    17325 	   uuid-ossp 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
    DROP EXTENSION "uuid-ossp";
                   false            �           0    0    EXTENSION "uuid-ossp"    COMMENT     W   COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';
                        false    2            �            1255    17376 0   insert_team(integer, character varying, integer)    FUNCTION     7  CREATE FUNCTION public.insert_team(teamtype integer, team character varying, uni integer) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE tmid uuid;
BEGIN
-- Insert into team
    INSERT INTO team (teamtypeid, teamname, uniid) VALUES (teamtype, team, uni)  RETURNING teamid INTO tmid;
	return tmid;
end;
$$;
 Y   DROP FUNCTION public.insert_team(teamtype integer, team character varying, uni integer);
       public          postgres    false            �            1255    17371 )   submit_code_file(character varying, uuid) 	   PROCEDURE     y  CREATE PROCEDURE public.submit_code_file(file character varying, vid uuid)
    LANGUAGE plpgsql
    AS $$
DECLARE subID int = 0;
begin
    -- insert submission into submission table
	INSERT INTO SUBMISSION (teamid) VALUES (vid) RETURNING submissionid INTO subID;
	
    -- insert file into file table
	INSERT INTO codefile(submissionid, filetext) VALUES (subid, file);
end;
$$;
 J   DROP PROCEDURE public.submit_code_file(file character varying, vid uuid);
       public          postgres    false            �            1259    17290    codefile    TABLE     [   CREATE TABLE public.codefile (
    submissionid integer,
    filetext character varying
);
    DROP TABLE public.codefile;
       public         heap    postgres    false            �            1259    17314    logs    TABLE     O   CREATE TABLE public.logs (
    runid integer,
    logtext character varying
);
    DROP TABLE public.logs;
       public         heap    postgres    false            �            1259    17303    run    TABLE     e   CREATE TABLE public.run (
    submissionid integer,
    runid integer NOT NULL,
    score integer
);
    DROP TABLE public.run;
       public         heap    postgres    false            �            1259    17301    run_runid_seq    SEQUENCE     �   CREATE SEQUENCE public.run_runid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.run_runid_seq;
       public          postgres    false    208            �           0    0    run_runid_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.run_runid_seq OWNED BY public.run.runid;
          public          postgres    false    207            �            1259    17277 
   submission    TABLE     �   CREATE TABLE public.submission (
    teamid uuid,
    submissionid integer NOT NULL,
    valid boolean DEFAULT false NOT NULL,
    submittime timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.submission;
       public         heap    postgres    false            �            1259    17275    submission_submissionid_seq    SEQUENCE     �   CREATE SEQUENCE public.submission_submissionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.submission_submissionid_seq;
       public          postgres    false    205            �           0    0    submission_submissionid_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.submission_submissionid_seq OWNED BY public.submission.submissionid;
          public          postgres    false    204            �            1259    17263    team    TABLE     �   CREATE TABLE public.team (
    teamid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    uniid integer,
    teamtypeid integer,
    teamname character varying(100) NOT NULL,
    CONSTRAINT team_teamname_check CHECK (((teamname)::text <> ''::text))
);
    DROP TABLE public.team;
       public         heap    postgres    false    2            �            1259    17339    teamtype    TABLE     �   CREATE TABLE public.teamtype (
    teamtypeid integer NOT NULL,
    teamtypename character varying(100) NOT NULL,
    CONSTRAINT teamtype_teamname_check CHECK (((teamtypename)::text <> ''::text))
);
    DROP TABLE public.teamtype;
       public         heap    postgres    false            �            1259    17337    teamtype_teamtypeid_seq    SEQUENCE     �   CREATE SEQUENCE public.teamtype_teamtypeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.teamtype_teamtypeid_seq;
       public          postgres    false    211            �           0    0    teamtype_teamtypeid_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.teamtype_teamtypeid_seq OWNED BY public.teamtype.teamtypeid;
          public          postgres    false    210            �            1259    17256 
   university    TABLE     �   CREATE TABLE public.university (
    uniid integer NOT NULL,
    uniname character varying(100) NOT NULL,
    CONSTRAINT university_uniname_check CHECK (((uniname)::text <> ''::text))
);
    DROP TABLE public.university;
       public         heap    postgres    false            �            1259    17254    university_uniid_seq    SEQUENCE     �   CREATE SEQUENCE public.university_uniid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.university_uniid_seq;
       public          postgres    false    202            �           0    0    university_uniid_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.university_uniid_seq OWNED BY public.university.uniid;
          public          postgres    false    201            V           2604    17306 	   run runid    DEFAULT     f   ALTER TABLE ONLY public.run ALTER COLUMN runid SET DEFAULT nextval('public.run_runid_seq'::regclass);
 8   ALTER TABLE public.run ALTER COLUMN runid DROP DEFAULT;
       public          postgres    false    208    207    208            S           2604    17280    submission submissionid    DEFAULT     �   ALTER TABLE ONLY public.submission ALTER COLUMN submissionid SET DEFAULT nextval('public.submission_submissionid_seq'::regclass);
 F   ALTER TABLE public.submission ALTER COLUMN submissionid DROP DEFAULT;
       public          postgres    false    204    205    205            W           2604    17342    teamtype teamtypeid    DEFAULT     z   ALTER TABLE ONLY public.teamtype ALTER COLUMN teamtypeid SET DEFAULT nextval('public.teamtype_teamtypeid_seq'::regclass);
 B   ALTER TABLE public.teamtype ALTER COLUMN teamtypeid DROP DEFAULT;
       public          postgres    false    210    211    211            O           2604    17259    university uniid    DEFAULT     t   ALTER TABLE ONLY public.university ALTER COLUMN uniid SET DEFAULT nextval('public.university_uniid_seq'::regclass);
 ?   ALTER TABLE public.university ALTER COLUMN uniid DROP DEFAULT;
       public          postgres    false    202    201    202            b           2606    17308    run run_pkey 
   CONSTRAINT     M   ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_pkey PRIMARY KEY (runid);
 6   ALTER TABLE ONLY public.run DROP CONSTRAINT run_pkey;
       public            postgres    false    208            `           2606    17284    submission submission_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_pkey PRIMARY KEY (submissionid);
 D   ALTER TABLE ONLY public.submission DROP CONSTRAINT submission_pkey;
       public            postgres    false    205            \           2606    17269    team team_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (teamid);
 8   ALTER TABLE ONLY public.team DROP CONSTRAINT team_pkey;
       public            postgres    false    203            ^           2606    17353    team team_teamname_key 
   CONSTRAINT     U   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_teamname_key UNIQUE (teamname);
 @   ALTER TABLE ONLY public.team DROP CONSTRAINT team_teamname_key;
       public            postgres    false    203            d           2606    17345    teamtype teamtype_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.teamtype
    ADD CONSTRAINT teamtype_pkey PRIMARY KEY (teamtypeid);
 @   ALTER TABLE ONLY public.teamtype DROP CONSTRAINT teamtype_pkey;
       public            postgres    false    211            Z           2606    17262    university university_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.university
    ADD CONSTRAINT university_pkey PRIMARY KEY (uniid);
 D   ALTER TABLE ONLY public.university DROP CONSTRAINT university_pkey;
       public            postgres    false    202            h           2606    17296 #   codefile codefile_submissionid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.codefile
    ADD CONSTRAINT codefile_submissionid_fkey FOREIGN KEY (submissionid) REFERENCES public.submission(submissionid);
 M   ALTER TABLE ONLY public.codefile DROP CONSTRAINT codefile_submissionid_fkey;
       public          postgres    false    206    205    2912            j           2606    17320    logs logs_runid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_runid_fkey FOREIGN KEY (runid) REFERENCES public.submission(submissionid);
 >   ALTER TABLE ONLY public.logs DROP CONSTRAINT logs_runid_fkey;
       public          postgres    false    205    209    2912            i           2606    17309    run run_submissionid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.run
    ADD CONSTRAINT run_submissionid_fkey FOREIGN KEY (submissionid) REFERENCES public.submission(submissionid);
 C   ALTER TABLE ONLY public.run DROP CONSTRAINT run_submissionid_fkey;
       public          postgres    false    2912    205    208            g           2606    17285 !   submission submission_teamid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.submission
    ADD CONSTRAINT submission_teamid_fkey FOREIGN KEY (teamid) REFERENCES public.team(teamid);
 K   ALTER TABLE ONLY public.submission DROP CONSTRAINT submission_teamid_fkey;
       public          postgres    false    205    203    2908            f           2606    17346    team team_teamtypeid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_teamtypeid_fkey FOREIGN KEY (teamtypeid) REFERENCES public.teamtype(teamtypeid);
 C   ALTER TABLE ONLY public.team DROP CONSTRAINT team_teamtypeid_fkey;
       public          postgres    false    2916    211    203            e           2606    17270    team team_uniid_fkey    FK CONSTRAINT     y   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_uniid_fkey FOREIGN KEY (uniid) REFERENCES public.university(uniid);
 >   ALTER TABLE ONLY public.team DROP CONSTRAINT team_uniid_fkey;
       public          postgres    false    2906    203    202           