with VGMStream; use VGMStream;

package VGMStream.Extra is
	-- Constants
	Sample_Buffer_Size : constant Natural := 32768; -- Sample Buffer Size

	Export_Exception : exception;

	function Get_Length (S : String) return Natural;
	function Get_Length_Seconds (S : String) return Float;
	procedure Export_Wav (O : String; I : String);

	-- Swap samples so that output is Little Endian
	procedure Swap_Samples_LE (A : System.Address; Count : int) 
	with
		Import => True,
		Convention => C;
end VGMStream.Extra;
