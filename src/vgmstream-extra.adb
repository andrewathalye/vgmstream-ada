with Ada.Text_IO; use Ada.Text_IO;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Interfaces.C; use Interfaces.C;
with Interfaces; use Interfaces;
with Ada.Directories; use Ada.Directories;

with VGMStream; use VGMStream;

package body VGMStream.Extra is
	-- WAV Header type
	type Wav_String is new String (1 .. 4);
	type Wav_Header is record
		RIFF : Wav_String := "RIFF";
		RIFF_Size : Unsigned_32;
		WAVE : Wav_String := "WAVE";
		WAVE_fmt : Wav_String := "fmt ";
		WAVE_fmt_Size : Unsigned_32 := 16#10#;
		Codec : Unsigned_16 := 1; -- PCM
		Channel_Count : Unsigned_16;
		Sample_Rate : Unsigned_32;
		Bytes_Per_Second : Unsigned_32;
		Block_Align : Unsigned_16;
		Significant_Bits_Per_Sample : Unsigned_16;
		WAVE_data : Wav_String := "data";
		WAVE_data_Size : Unsigned_32;
	end record;

	-- Get duration of file given path (VGMStream)
	function Get_Length (S : String) return Natural is
		V : VGMStream_Access := VGMStream_Init (S);
		I : Natural;
	begin
		if V /= null then
			VGMStream_Apply_Config (V, VGMStream_CLI_Config'Access); -- Set fade time, etc. so samples match vgmstream-cli
			I := VGMStream_Get_Samples (V);
			VGMStream_Close (V);
		else
			Put_Line (Standard_Error, "[Error] Failed to process file: " & S);
			I := 0;
		end if;
		return I;
	end Get_Length;

	-- Get duration in seconds of file given path
	function Get_Length_Seconds (S : String) return Float is
		V : VGMStream_Access := VGMStream_Init (S);
		F : Float;
	begin
		if V /= null then
			VGMStream_Apply_Config (V, VGMStream_CLI_Config'Access);
			F := (Float (VGMStream.VGMStream_Get_Samples (V))) / (Float (VGMStream_Get_Sample_Rate (V)));
			VGMStream_Close (V);
		else
			Put_Line (Standard_Error, "[Error] Failed to process file: " & S);
			F := 0.0;
		end if;
		return F;
	end Get_Length_Seconds;

	-- Create and write WAV header given VGMStream instance and Stream
	function Wav_Header_Create (V : VGMStream_Access) return Wav_Header is
		-- Data size
		D : constant Unsigned_32 := Unsigned_32 (VGMStream_Get_Samples (V) * Natural (V.all.channels)) * Unsigned_32 (Sample_Type'Size / 8);
	begin
		return Wav_Header'(RIFF_Size => 16#2c# - 16#8# + D,
			Channel_Count => Unsigned_16 (V.all.channels),
			Sample_Rate => Unsigned_32 (V.all.sample_rate),
			Bytes_Per_Second => Unsigned_32 (V.all.sample_rate) * Unsigned_32 (V.all.channels) * Unsigned_32 (Sample_Type'Size / 8),
			Block_Align => Unsigned_16 (V.all.channels * (Sample_Type'Size / 8)),
			Significant_Bits_Per_Sample => Unsigned_16 (Sample_Type'Size),
			WAVE_data_Size => D,
			others => <>);
			
	end Wav_Header_Create;

	-- Export VGMStream input file to WAV file
	procedure Export_Wav (O : String; I : String) is
		V : VGMStream_Access := VGMStream_Init (I);
	begin	
		if V = null then
			raise Export_Exception with "Could not create VGMStream";
		end if;

		Export_Wav (O, V);
	end Export_Wav;

	-- More rudimentary exporter that takes a VGMStream_Access
	procedure Export_Wav (
		O : String;
		V : VGMStream_Access)
	is
		F : Ada.Streams.Stream_IO.File_Type;
		S : Stream_Access;
	begin
		if V = null then
			raise Export_Exception with "Invalid VGMStream provided";
		end if;

		if Exists (O) then
			raise Export_Exception with "File exists";
		end if;

		Create (F, Out_File, O);
		S := Stream (F);

		-- Apply config so that export length will be correct
		VGMStream_Apply_Config (V, VGMStream_CLI_Config'Access);
		Wav_Header'Write (S, Wav_Header_Create (V));

		declare
			L : constant Natural := VGMStream_Get_Samples (V); -- Samples Length
			B : aliased Sample_Buffer (1 .. Sample_Buffer_Size * Natural (V.all.channels));
			I : Natural := 0;
			T : Natural; -- To Get
		begin
			while I < L loop
				T := (if I + Sample_Buffer_Size > L then L - I else Sample_Buffer_Size); -- Target samples export
				if VGMStream_Render (B'Address, int (T), V) /= int (T) then
					Put_Line (Standard_Error, "[Warning] Less samples than expected returned");
				end if;

				Swap_Samples_LE (B'Address, V.all.channels * int (T));
				Sample_Buffer'Write (S, B);	

				I := I + Sample_Buffer_Size;
			end loop;
		end;
	
		Close (F);
		VGMStream_Close (V);
	end Export_Wav;
	
end VGMStream.Extra;
