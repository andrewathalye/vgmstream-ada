with Interfaces.C; use Interfaces.C;
with System; use System;

with VGMStream_Internal; use VGMStream_Internal;

package VGMStream is

	-- Types
	subtype Sample_Type is VGMStream_Internal.Sample_Type;
	type Sample_Buffer is array (Natural range <>) of Sample_Type;
	type VGMStream_Access is access VGMStream_Type;

	-- Constants
	VGMStream_CLI_Config : aliased constant VGMStream_Config := (disable_config_override => 0,
		allow_play_forever => 0,
		play_forever => 0,
		fade_time => 10.0,
		loop_count => 2.0,
		fade_delay => 0.0,
		ignore_loop => 0,
		force_loop => 0,
		really_force_loop => 0,
		ignore_fade => 0);

	-- Subprograms
	
	-- Init VGMStream from path of input file
	function VGMStream_Init (S : String) return VGMStream_Access;

	-- Close VGMStream
	procedure VGMStream_Close (V : VGMStream_Access)
	with
		Import => True,
		Convention => C,
		External_Name => "close_vgmstream";

	-- Read Number of Samples
	function VGMStream_Get_Samples (V : VGMStream_Access) return Natural;

	-- Read Sample Rate
	function VGMStream_Get_Sample_Rate (V : VGMStream_Access) return Natural is (Natural (V.all.sample_rate));

	-- Render VGMStream into Buffer (must have appropriate space for N samples)
	-- Return number of samples transferred (can be less than N)
	function VGMStream_Render (Out_Buf : System.Address; N : int; V : VGMStream_Access) return int
	with
		Import => True,
		Convention => C,
		External_Name => "render_vgmstream";

	-- Apply Configuration
	procedure VGMStream_Apply_Config (V : VGMStream_Access; C : access constant VGMStream_Config)
	with
		Import => True,
		Convention => C,
		External_Name => "vgmstream_apply_config";

end VGMStream;
