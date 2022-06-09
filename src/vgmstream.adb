with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings; use Interfaces.C.Strings;

package body VGMStream is
	-- Not Public (Raw C interface)
	function init_vgmstream (C : chars_ptr) return VGMStream_Access
	with
		Import => True,
		Convention => C;

	-- Init VGMStream from path of input file
	function VGMStream_Init (S : String) return VGMStream_Access is
		C : chars_ptr := New_String (S);
		A : VGMStream_Access;
	begin
		A := VGMStream_Access (init_vgmstream (C));
		Free (C); -- String no longer needed by vgmstream after stream initialised
		return A;
	end VGMStream_Init;

	-- Read samples from VGMStream	
	-- Based on src/render.c:63
	-- Logically cannot be less than zero
	function VGMStream_Get_Samples (V : VGMStream_Access) return Natural is
	begin
		if V.all.config_enabled = 0 or V.all.config.config_set = 0 then
			return Natural (V.all.num_samples);
		end if;
		return Natural (V.all.pstate.play_duration);
	end VGMStream_Get_Samples;
end VGMStream;
