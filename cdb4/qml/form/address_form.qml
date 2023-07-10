<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.16-Białowieża">
  <fieldConfiguration>
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid_codespace">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="street">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="house_number">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="po_box">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="zip_code">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="city">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="state">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="country">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field configurationFlags="None" name="cityobject_id">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option value="false" name="IsMultiline" type="bool"/>
            <Option value="false" name="UseHtml" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" index="0" name="Database ID"/>
    <alias field="gmlid" index="1" name="GML ID"/>
    <alias field="gmlid_codespace" index="2" name="GML codespace"/>
    <alias field="street" index="3" name="Street"/>
    <alias field="house_number" index="4" name="House number"/>
    <alias field="po_box" index="5" name="PO box"/>
    <alias field="zip_code" index="6" name="ZIP code"/>
    <alias field="city" index="7" name="City"/>
    <alias field="state" index="8" name="State"/>
    <alias field="country" index="9" name="Country"/>
    <alias field="cityobject_id" index="10" name="Parent ID"/>
  </aliases>
  <defaults></defaults>
  <constraints>
    <constraint notnull_strength="2" field="id" unique_strength="2" exp_strength="0" constraints="3"/>
  </constraints>
  <constraintExpressions></constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorField showLabel="1" index="0" name="id"/>
    <attributeEditorField showLabel="1" index="1" name="gmlid"/>
    <attributeEditorField showLabel="1" index="2" name="gmlid_codespace"/>
    <attributeEditorField showLabel="1" index="3" name="street"/>
    <attributeEditorField showLabel="1" index="4" name="house_number"/>
    <attributeEditorField showLabel="1" index="5" name="po_box"/>
    <attributeEditorField showLabel="1" index="6" name="zip_code"/>
    <attributeEditorField showLabel="1" index="7" name="city"/>
    <attributeEditorField showLabel="1" index="8" name="state"/>
    <attributeEditorField showLabel="1" index="9" name="country"/>
    <attributeEditorField showLabel="1" index="10" name="cityobject_id"/>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="id"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="1" name="street"/>
    <field editable="1" name="house_number"/>
    <field editable="1" name="zip_code"/>
    <field editable="1" name="po_box"/>
    <field editable="1" name="city"/>
    <field editable="1" name="country"/>
    <field editable="1" name="state"/>
    <field editable="0" name="cityobject_id"/>
  </editable>
  <labelOnTop></labelOnTop>
  <reuseLastValue></reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
</qgis>
