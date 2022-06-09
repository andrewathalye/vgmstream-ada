with Interfaces.C; use Interfaces.C;
with Interfaces; use Interfaces;
with System;

package VGMStream_Internal is
	-- Constants	
	

	-- Channel (Opaque)
	type VGMStream_Channel is private;
	type VGMStream_Channel_Access is access VGMStream_Channel;

	-- Coding, Layout, and Meta (Private)
	type Coding_Type is private;
	type Layout_Type is private;
	type Meta_Type is private;

	-- Offset -- TODO May not be portable
	subtype off_t is long;

	-- Stream Name
	subtype Stream_Name_Type is char_array (0 .. 254);

	-- Sample
	subtype Sample_Type is Integer_16; -- streamtypes.h

	-- Play State and Play Config
	type Play_Config_Type is record -- vgmstream.h
		config_set : int;

		-- General Modifiers
		play_forever : int;
		ignore_loop : int;
		force_loop : int;
		really_force_loop : int;
		ignore_fade : int;

		-- Processing
		loop_count : double;
		pad_begin : Integer_32;
		trim_begin : Integer_32;
		body_time : Integer_32;
		trim_end : Integer_32;
		fade_delay : double;
		fade_time : double;
		pad_end : Integer_32;

		pad_begin_s : double;
		trim_begin_s : double;
		body_time_s : double;
		trim_end_s : double;
		pad_end_s : double;

		-- Internal Flags
		pad_begin_set : int;
		trim_begin_set : int;
		body_time_set : int;
		loop_count_set : int;
		trim_end_set : int;
		fade_delay_set : int;
		fade_time_set : int;
		pad_end_set : int;

		-- Miscellaneous
		is_txtp : int;
		is_mini_txtp : int;
	end record;

	type Play_State_Type is record -- vgmstream.h
		input_channels : int;
		output_channels : int;

		pad_begin_duration : Integer_32;
		pad_begin_left : Integer_32;
		trim_begin_duration : Integer_32;
		trim_begin_left : Integer_32;
		body_duration : Integer_32;
		fade_duration : Integer_32;
		fade_left : Integer_32;
		fade_start : Integer_32;
		pad_end_duration : Integer_32;
		pad_end_start : Integer_32;

		play_duration : Integer_32;
		play_position : Integer_32;
	end record;

	-- VGMStream Record Definition
	type VGMStream_Type is record -- vgmstream.h 
		-- Basic configuration
		num_samples : Integer_32;
		sample_rate : Integer_32;
		channels : int;
		coding : Coding_Type;
		layout : Layout_Type;
		meta : Meta_Type;

		-- Loop configuration
		loop_flag : int;
		loop_start_sample : Integer_32;
		loop_end_sample : Integer_32;

		-- Layouts / block configuration
		interleave_block_size : size_t;
		interleave_first_block_size : size_t;
		interleave_first_skip : size_t;
		interleave_last_block_size : size_t;
		frame_size : size_t;

		-- Subsong configuration
		num_streams : int;
		stream_index : int;
		stream_size : size_t;
		stream_name : Stream_Name_Type;

		-- Mapping configuration
		channel_layout : Unsigned_32; -- See vgmstream.h for definition

		-- Miscellaneous
		allow_dual_stereo : int;
	
		-- Layout / block state
		full_block_size : size_t;
		current_sample : Integer_32;
		samples_into_block : Integer_32;
		current_block_offset : off_t;
		current_block_size : size_t;
		current_block_samples : Integer_32;
		next_block_offset : off_t;

		-- Loop state
		loop_current_sample : Integer_32;
		loop_samples_into_block : Integer_32;
		loop_block_offset : off_t;
		loop_block_size : size_t;
		loop_block_samples : Integer_32;
		loop_next_block_offset : off_t;
		hit_loop : int; -- Used as Boolean

		-- Decoder configuration / state
		codec_endian : int;
		codec_config : int;
		ws_output_size : Integer_32;

		-- Main state
		ch : VGMStream_Channel_Access;
		start_ch : VGMStream_Channel_Access;
		loop_ch : VGMStream_Channel_Access;
		start_vgmstream : System.Address; -- Pointer to original VGMStream before playback start

		-- Mixing effect states
		mixing_data : System.Address;

		-- Optional, unorganised data
		codec_data : System.Address;
		layout_data : System.Address;

		-- Play configuration
		config_enabled : int;
		config : Play_Config_Type;
		pstate : Play_State_Type;
		loop_count : int;
		loop_target : int;
		tmpbuf : access Sample_Type;
		tmpbuf_size : size_t;

	end record;

	-- Configuration for VGMStream Playback
	type VGMStream_Config is record -- plugins.h
		allow_play_forever : int;
		disable_config_override : int;

		-- Song Modifiers
		play_forever : int;
		ignore_loop : int;
		force_loop : int;
		really_force_loop : int;
		ignore_fade : int;

		loop_count : double;
		fade_delay : double;
		fade_time : double;
	end record;
private
	type VGMStream_Channel is null record;

	-- Encoding types supported
	type Coding_Type is -- vgmstream.h
	     (coding_SILENCE,
	      coding_PCM16LE,
	      coding_PCM16BE,
	      coding_PCM16_int,
	      coding_PCM8,
	      coding_PCM8_int,
	      coding_PCM8_U,
	      coding_PCM8_U_int,
	      coding_PCM8_SB,
	      coding_PCM4,
	      coding_PCM4_U,
	      coding_ULAW,
	      coding_ULAW_int,
	      coding_ALAW,
	      coding_PCMFLOAT,
	      coding_PCM24LE,
	      coding_CRI_ADX,
	      coding_CRI_ADX_fixed,
	      coding_CRI_ADX_exp,
	      coding_CRI_ADX_enc_8,
	      coding_CRI_ADX_enc_9,
	      coding_NGC_DSP,
	      coding_NGC_DSP_subint,
	      coding_NGC_DTK,
	      coding_NGC_AFC,
	      coding_VADPCM,
	      coding_G721,
	      coding_XA,
	      coding_XA8,
	      coding_XA_EA,
	      coding_PSX,
	      coding_PSX_badflags,
	      coding_PSX_cfg,
	      coding_PSX_pivotal,
	      coding_HEVAG,
	      coding_EA_XA,
	      coding_EA_XA_int,
	      coding_EA_XA_V2,
	      coding_MAXIS_XA,
	      coding_EA_XAS_V0,
	      coding_EA_XAS_V1,
	      coding_IMA,
	      coding_IMA_int,
	      coding_DVI_IMA,
	      coding_DVI_IMA_int,
	      coding_3DS_IMA,
	      coding_SNDS_IMA,
	      coding_QD_IMA,
	      coding_WV6_IMA,
	      coding_ALP_IMA,
	      coding_FFTA2_IMA,
	      coding_BLITZ_IMA,
	      coding_MS_IMA,
	      coding_XBOX_IMA,
	      coding_XBOX_IMA_mch,
	      coding_XBOX_IMA_int,
	      coding_NDS_IMA,
	      coding_DAT4_IMA,
	      coding_RAD_IMA,
	      coding_RAD_IMA_mono,
	      coding_APPLE_IMA4,
	      coding_FSB_IMA,
	      coding_WWISE_IMA,
	      coding_REF_IMA,
	      coding_AWC_IMA,
	      coding_UBI_IMA,
	      coding_UBI_SCE_IMA,
	      coding_H4M_IMA,
	      coding_MTF_IMA,
	      coding_CD_IMA,
	      coding_MSADPCM,
	      coding_MSADPCM_int,
	      coding_MSADPCM_ck,
	      coding_WS,
	      coding_AICA,
	      coding_AICA_int,
	      coding_CP_YM,
	      coding_ASKA,
	      coding_NXAP,
	      coding_TGC,
	      coding_NDS_PROCYON,
	      coding_L5_555,
	      coding_LSF,
	      coding_MTAF,
	      coding_MTA2,
	      coding_MC3,
	      coding_FADPCM,
	      coding_ASF,
	      coding_DSA,
	      coding_XMD,
	      coding_TANTALUS,
	      coding_PCFX,
	      coding_OKI16,
	      coding_OKI4S,
	      coding_PTADPCM,
	      coding_IMUSE,
	      coding_COMPRESSWAVE,
	      coding_SDX2,
	      coding_SDX2_int,
	      coding_CBD2,
	      coding_CBD2_int,
	      coding_SASSC,
	      coding_DERF,
	      coding_WADY,
	      coding_NWA,
	      coding_ACM,
	      coding_CIRCUS_ADPCM,
	      coding_UBI_ADPCM,
	      coding_EA_MT,
	      coding_CIRCUS_VQ,
	      coding_RELIC,
	      coding_CRI_HCA,
	      coding_TAC)
	   with Convention => C;

	-- Supported layouts
	type Layout_Type is  -- vgmstream.h
	     (layout_none,
	      layout_interleave,
	      layout_blocked_ast,
	      layout_blocked_halpst,
	      layout_blocked_xa,
	      layout_blocked_ea_schl,
	      layout_blocked_ea_1snh,
	      layout_blocked_caf,
	      layout_blocked_wsi,
	      layout_blocked_str_snds,
	      layout_blocked_ws_aud,
	      layout_blocked_matx,
	      layout_blocked_dec,
	      layout_blocked_xvas,
	      layout_blocked_vs,
	      layout_blocked_mul,
	      layout_blocked_gsb,
	      layout_blocked_thp,
	      layout_blocked_filp,
	      layout_blocked_ea_swvr,
	      layout_blocked_adm,
	      layout_blocked_bdsp,
	      layout_blocked_mxch,
	      layout_blocked_ivaud,
	      layout_blocked_tra,
	      layout_blocked_ps2_iab,
	      layout_blocked_vs_str,
	      layout_blocked_rws,
	      layout_blocked_hwas,
	      layout_blocked_ea_sns,
	      layout_blocked_awc,
	      layout_blocked_vgs,
	      layout_blocked_xwav,
	      layout_blocked_xvag_subsong,
	      layout_blocked_ea_wve_au00,
	      layout_blocked_ea_wve_ad10,
	      layout_blocked_sthd,
	      layout_blocked_h4m,
	      layout_blocked_xa_aiff,
	      layout_blocked_vs_square,
	      layout_blocked_vid1,
	      layout_blocked_ubi_sce,
	      layout_segmented,
	      layout_layered)
	   with Convention => C;

	type Meta_Type is -- vgmstream.h
	     (meta_SILENCE,
	      meta_DSP_STD,
	      meta_DSP_CSTR,
	      meta_DSP_RS03,
	      meta_DSP_STM,
	      meta_AGSC,
	      meta_CSMP,
	      meta_RFRM,
	      meta_DSP_MPDSP,
	      meta_DSP_JETTERS,
	      meta_DSP_MSS,
	      meta_DSP_GCM,
	      meta_DSP_STR,
	      meta_DSP_SADB,
	      meta_DSP_WSI,
	      meta_IDSP_TT,
	      meta_DSP_WII_MUS,
	      meta_DSP_WII_WSD,
	      meta_WII_NDP,
	      meta_DSP_YGO,
	      meta_STRM,
	      meta_RSTM,
	      meta_AFC,
	      meta_AST,
	      meta_RWSD,
	      meta_RWAR,
	      meta_RWAV,
	      meta_CWAV,
	      meta_FWAV,
	      meta_RSTM_SPM,
	      meta_THP,
	      meta_RSTM_shrunken,
	      meta_SWAV,
	      meta_NDS_RRDS,
	      meta_WII_BNS,
	      meta_WIIU_BTSND,
	      meta_ADX_03,
	      meta_ADX_04,
	      meta_ADX_05,
	      meta_AIX,
	      meta_AAX,
	      meta_UTF_DSP,
	      meta_DTK,
	      meta_RSF,
	      meta_HALPST,
	      meta_GCSW,
	      meta_CAF,
	      meta_MYSPD,
	      meta_HIS,
	      meta_BNSF,
	      meta_XA,
	      meta_ADS,
	      meta_NPS,
	      meta_RXWS,
	      meta_RAW_INT,
	      meta_EXST,
	      meta_SVAG_KCET,
	      meta_PS_HEADERLESS,
	      meta_MIB_MIH,
	      meta_PS2_MIC,
	      meta_PS2_VAGi,
	      meta_PS2_VAGp,
	      meta_PS2_pGAV,
	      meta_PS2_VAGp_AAAP,
	      meta_SEB,
	      meta_STR_WAV,
	      meta_ILD,
	      meta_PS2_PNB,
	      meta_VPK,
	      meta_PS2_BMDX,
	      meta_PS2_IVB,
	      meta_PS2_SND,
	      meta_SVS,
	      meta_XSS,
	      meta_SL3,
	      meta_HGC1,
	      meta_AUS,
	      meta_RWS,
	      meta_FSB1,
	      meta_FSB2,
	      meta_FSB3,
	      meta_FSB4,
	      meta_FSB5,
	      meta_RWX,
	      meta_XWB,
	      meta_PS2_XA30,
	      meta_MUSC,
	      meta_MUSX,
	      meta_LEG,
	      meta_FILP,
	      meta_IKM,
	      meta_STER,
	      meta_BG00,
	      meta_PS2_RSTM,
	      meta_PS2_KCES,
	      meta_PS2_DXH,
	      meta_VSV,
	      meta_SCD_PCM,
	      meta_PS2_PCM,
	      meta_PS2_RKV,
	      meta_PS2_VAS,
	      meta_PS2_TEC,
	      meta_PS2_ENTH,
	      meta_SDT,
	      meta_NGC_TYDSP,
	      meta_CAPDSP,
	      meta_DC_STR,
	      meta_DC_STR_V2,
	      meta_NGC_BH2PCM,
	      meta_SAP,
	      meta_DC_IDVI,
	      meta_KRAW,
	      meta_PS2_OMU,
	      meta_PS2_XA2,
	      meta_NUB,
	      meta_IDSP_NL,
	      meta_IDSP_IE,
	      meta_SPT_SPD,
	      meta_ISH_ISD,
	      meta_GSP_GSB,
	      meta_YDSP,
	      meta_FFCC_STR,
	      meta_UBI_JADE,
	      meta_GCA,
	      meta_NGC_SSM,
	      meta_PS2_JOE,
	      meta_NGC_YMF,
	      meta_SADL,
	      meta_PS2_CCC,
	      meta_FAG,
	      meta_PS2_MIHB,
	      meta_NGC_PDT,
	      meta_DC_ASD,
	      meta_NAOMI_SPSD,
	      meta_RSD,
	      meta_PS2_ASS,
	      meta_SEG,
	      meta_NDS_STRM_FFTA2,
	      meta_KNON,
	      meta_ZWDSP,
	      meta_VGS,
	      meta_DCS_WAV,
	      meta_SMP,
	      meta_WII_SNG,
	      meta_MUL,
	      meta_SAT_BAKA,
	      meta_VSF,
	      meta_PS2_VSF_TTA,
	      meta_ADS_MIDWAY,
	      meta_PS2_SPS,
	      meta_PS2_XA2_RRP,
	      meta_NGC_DSP_KONAMI,
	      meta_UBI_CKD,
	      meta_RAW_WAVM,
	      meta_WVS,
	      meta_XBOX_MATX,
	      meta_XMU,
	      meta_XVAS,
	      meta_EA_SCHL,
	      meta_EA_SCHL_fixed,
	      meta_EA_BNK,
	      meta_EA_1SNH,
	      meta_EA_EACS,
	      meta_RAW_PCM,
	      meta_GENH,
	      meta_AIFC,
	      meta_AIFF,
	      meta_STR_SNDS,
	      meta_WS_AUD,
	      meta_WS_AUD_old,
	      meta_RIFF_WAVE,
	      meta_RIFF_WAVE_POS,
	      meta_RIFF_WAVE_labl,
	      meta_RIFF_WAVE_smpl,
	      meta_RIFF_WAVE_wsmp,
	      meta_RIFF_WAVE_MWV,
	      meta_RIFX_WAVE,
	      meta_RIFX_WAVE_smpl,
	      meta_XNB,
	      meta_PC_MXST,
	      meta_SAB,
	      meta_NWA,
	      meta_NWA_NWAINFOINI,
	      meta_NWA_GAMEEXEINI,
	      meta_SAT_DVI,
	      meta_DC_KCEY,
	      meta_ACM,
	      meta_MUS_ACM,
	      meta_DEC,
	      meta_VS,
	      meta_FFXI_BGW,
	      meta_FFXI_SPW,
	      meta_STS,
	      meta_PS2_P2BT,
	      meta_PS2_GBTS,
	      meta_NGC_DSP_IADP,
	      meta_PS2_TK5,
	      meta_PS2_MCG,
	      meta_ZSD,
	      meta_REDSPARK,
	      meta_IVAUD,
	      meta_NDS_HWAS,
	      meta_NGC_LPS,
	      meta_NAOMI_ADPCM,
	      meta_SD9,
	      meta_2DX9,
	      meta_PS2_VGV,
	      meta_GCUB,
	      meta_MAXIS_XA,
	      meta_NGC_SCK_DSP,
	      meta_CAFF,
	      meta_EXAKT_SC,
	      meta_WII_WAS,
	      meta_PONA_3DO,
	      meta_PONA_PSX,
	      meta_XBOX_HLWAV,
	      meta_AST_MV,
	      meta_AST_MMV,
	      meta_DMSG,
	      meta_NGC_DSP_AAAP,
	      meta_PS2_WB,
	      meta_S14,
	      meta_SSS,
	      meta_PS2_GCM,
	      meta_PS2_SMPL,
	      meta_PS2_MSA,
	      meta_PS2_VOI,
	      meta_P3D,
	      meta_PS2_TK1,
	      meta_NGC_RKV,
	      meta_DSP_DDSP,
	      meta_NGC_DSP_MPDS,
	      meta_DSP_STR_IG,
	      meta_EA_SWVR,
	      meta_PS2_B1S,
	      meta_PS2_WAD,
	      meta_DSP_XIII,
	      meta_DSP_CABELAS,
	      meta_PS2_ADM,
	      meta_LPCM_SHADE,
	      meta_DSP_BDSP,
	      meta_PS2_VMS,
	      meta_XAU,
	      meta_GH3_BAR,
	      meta_FFW,
	      meta_DSP_DSPW,
	      meta_PS2_JSTM,
	      meta_SQEX_SCD,
	      meta_NGC_NST_DSP,
	      meta_BAF,
	      meta_XVAG,
	      meta_PS3_CPS,
	      meta_MSF,
	      meta_PS3_PAST,
	      meta_SGXD,
	      meta_WII_RAS,
	      meta_SPM,
	      meta_X360_TRA,
	      meta_VGS_PS,
	      meta_PS2_IAB,
	      meta_VS_STR,
	      meta_LSF_N1NJ4N,
	      meta_XWAV,
	      meta_RAW_SNDS,
	      meta_PS2_WMUS,
	      meta_HYPERSCAN_KVAG,
	      meta_IOS_PSND,
	      meta_BOS_ADP,
	      meta_QD_ADP,
	      meta_EB_SFX,
	      meta_EB_SF0,
	      meta_MTAF,
	      meta_PS2_VAG1,
	      meta_PS2_VAG2,
	      meta_TUN,
	      meta_WPD,
	      meta_MN_STR,
	      meta_MSS,
	      meta_PS2_HSF,
	      meta_IVAG,
	      meta_PS2_2PFS,
	      meta_PS2_VBK,
	      meta_OTM,
	      meta_CSTM,
	      meta_FSTM,
	      meta_IDSP_NAMCO,
	      meta_KT_WIIBGM,
	      meta_KTSS,
	      meta_MCA,
	      meta_XB3D_ADX,
	      meta_HCA,
	      meta_SVAG_SNK,
	      meta_PS2_VDS_VDM,
	      meta_FFMPEG,
	      meta_X360_CXS,
	      meta_AKB,
	      meta_X360_PASX,
	      meta_XMA_RIFF,
	      meta_X360_AST,
	      meta_WWISE_RIFF,
	      meta_UBI_RAKI,
	      meta_SXD,
	      meta_OGL,
	      meta_MC3,
	      meta_GTD,
	      meta_TA_AAC,
	      meta_MTA2,
	      meta_NGC_ULW,
	      meta_XA_XA30,
	      meta_XA_04SW,
	      meta_TXTH,
	      meta_SK_AUD,
	      meta_AHX,
	      meta_STM,
	      meta_BINK,
	      meta_EA_SNU,
	      meta_AWC,
	      meta_OPUS,
	      meta_RAW_AL,
	      meta_PC_AST,
	      meta_NAAC,
	      meta_UBI_SB,
	      meta_EZW,
	      meta_VXN,
	      meta_EA_SNR_SNS,
	      meta_EA_SPS,
	      meta_VID1,
	      meta_PC_FLX,
	      meta_MOGG,
	      meta_OGG_VORBIS,
	      meta_OGG_SLI,
	      meta_OPUS_SLI,
	      meta_OGG_SFL,
	      meta_OGG_KOVS,
	      meta_OGG_encrypted,
	      meta_KMA9,
	      meta_XWC,
	      meta_SQEX_SAB,
	      meta_SQEX_MAB,
	      meta_WAF,
	      meta_WAVE,
	      meta_WAVE_segmented,
	      meta_SMV,
	      meta_NXAP,
	      meta_EA_WVE_AU00,
	      meta_EA_WVE_AD10,
	      meta_STHD,
	      meta_MP4,
	      meta_PCM_SRE,
	      meta_DSP_MCADPCM,
	      meta_UBI_LYN,
	      meta_MSB_MSH,
	      meta_TXTP,
	      meta_SMC_SMH,
	      meta_PPST,
	      meta_SPS_N1,
	      meta_UBI_BAO,
	      meta_DSP_SWITCH_AUDIO,
	      meta_H4M,
	      meta_ASF,
	      meta_XMD,
	      meta_CKS,
	      meta_CKB,
	      meta_WV6,
	      meta_WAVEBATCH,
	      meta_HD3_BD3,
	      meta_BNK_SONY,
	      meta_SCD_SSCF,
	      meta_DSP_VAG,
	      meta_DSP_ITL,
	      meta_A2M,
	      meta_AHV,
	      meta_MSV,
	      meta_SDF,
	      meta_SVG,
	      meta_VIS,
	      meta_VAI,
	      meta_AIF_ASOBO,
	      meta_AO,
	      meta_APC,
	      meta_WV2,
	      meta_XAU_KONAMI,
	      meta_DERF,
	      meta_SADF,
	      meta_UTK,
	      meta_NXA,
	      meta_ADPCM_CAPCOM,
	      meta_UE4OPUS,
	      meta_XWMA,
	      meta_VA3,
	      meta_XOPUS,
	      meta_VS_SQUARE,
	      meta_NWAV,
	      meta_XPCM,
	      meta_MSF_TAMASOFT,
	      meta_XPS_DAT,
	      meta_ZSND,
	      meta_DSP_ADPY,
	      meta_DSP_ADPX,
	      meta_OGG_OPUS,
	      meta_IMC,
	      meta_GIN,
	      meta_DSF,
	      meta_208,
	      meta_DSP_DS2,
	      meta_MUS_VC,
	      meta_STRM_ABYLIGHT,
	      meta_MSF_KONAMI,
	      meta_XWMA_KONAMI,
	      meta_9TAV,
	      meta_BWAV,
	      meta_RAD,
	      meta_SMACKER,
	      meta_MZRT,
	      meta_XAVS,
	      meta_PSF,
	      meta_DSP_ITL_i,
	      meta_IMA,
	      meta_XMV_VALVE,
	      meta_UBI_HX,
	      meta_BMP_KONAMI,
	      meta_ISB,
	      meta_XSSB,
	      meta_XMA_UE3,
	      meta_FWSE,
	      meta_FDA,
	      meta_TGC,
	      meta_KWB,
	      meta_LRMD,
	      meta_WWISE_FX,
	      meta_DIVA,
	      meta_IMUSE,
	      meta_KTSR,
	      meta_KAT,
	      meta_PCM_SUCCESS,
	      meta_ADP_KONAMI,
	      meta_SDRH,
	      meta_WADY,
	      meta_DSP_SQEX,
	      meta_DSP_WIIVOICE,
	      meta_SBK,
	      meta_DSP_WIIADPCM,
	      meta_DSP_CWAC,
	      meta_COMPRESSWAVE,
	      meta_KTAC,
	      meta_MJB_MJH,
	      meta_BSNF,
	      meta_TAC,
	      meta_IDSP_TOSE,
	      meta_DSP_KWA,
	      meta_OGV_3RDEYE,
	      meta_PIFF_TPCM,
	      meta_WXD_WXH,
	      meta_BNK_RELIC,
	      meta_XSH_XSD_XSS,
	      meta_PSB,
	      meta_LOPU_FB,
	      meta_LPCM_FB,
	      meta_WBK,
	      meta_WBK_NSLB,
	      meta_DSP_APEX,
	      meta_MPEG)
	   with Convention => C;
end VGMStream_Internal;
